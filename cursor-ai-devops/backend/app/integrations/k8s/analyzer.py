from typing import Any, Dict, List
import yaml


def _ensure_list(value: Any) -> List[Any]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    return [value]


def analyze_manifest(manifest_yaml: str) -> List[Dict[str, Any]]:
    """Lightweight static checks for common K8s security/perf issues.

    Returns a list of findings: {severity, resource, message, rule}
    """
    findings: List[Dict[str, Any]] = []
    docs = list(yaml.safe_load_all(manifest_yaml))
    for doc in docs:
        if not isinstance(doc, dict):
            continue
        kind = doc.get("kind", "Unknown")
        metadata = doc.get("metadata", {}) or {}
        name = metadata.get("name", "unknown")
        spec = doc.get("spec", {}) or {}
        resource_id = f"{kind}/{name}"

        # Check image tags not 'latest'
        template = spec.get("template", {}) if "template" in spec else doc.get("template", {})
        pod_spec = template.get("spec", {}) if template else spec.get("spec", {})
        containers = _ensure_list(pod_spec.get("containers"))
        for c in containers:
            image = c.get("image", "")
            if ":" not in image or image.endswith(":latest"):
                findings.append({
                    "severity": "medium",
                    "resource": resource_id,
                    "message": f"Container {c.get('name','?')} uses a floating tag or latest: {image}",
                    "rule": "image-tag-not-latest",
                })

            # Resources
            resources = c.get("resources", {}) or {}
            if not resources.get("requests") or not resources.get("limits"):
                findings.append({
                    "severity": "medium",
                    "resource": resource_id,
                    "message": f"Container {c.get('name','?')} missing resource requests/limits",
                    "rule": "resources-requests-limits-required",
                })

            # Security context
            sc = c.get("securityContext", {}) or {}
            if sc.get("runAsNonRoot") is not True:
                findings.append({
                    "severity": "high",
                    "resource": resource_id,
                    "message": f"Container {c.get('name','?')} should set securityContext.runAsNonRoot=true",
                    "rule": "run-as-non-root",
                })
            if sc.get("allowPrivilegeEscalation") is not False:
                findings.append({
                    "severity": "high",
                    "resource": resource_id,
                    "message": f"Container {c.get('name','?')} should set allowPrivilegeEscalation=false",
                    "rule": "no-priv-esc",
                })
            caps = (sc.get("capabilities", {}) or {}).get("drop", [])
            if "ALL" not in caps:
                findings.append({
                    "severity": "medium",
                    "resource": resource_id,
                    "message": f"Container {c.get('name','?')} should drop ALL capabilities",
                    "rule": "capabilities-drop-all",
                })

        # Pod-level checks
        if pod_spec:
            if pod_spec.get("hostNetwork") is True:
                findings.append({
                    "severity": "high",
                    "resource": resource_id,
                    "message": "hostNetwork=true increases risk; avoid unless required",
                    "rule": "no-host-network",
                })
            if pod_spec.get("serviceAccountName") in (None, "default"):
                findings.append({
                    "severity": "medium",
                    "resource": resource_id,
                    "message": "Explicit serviceAccountName recommended (avoid default)",
                    "rule": "explicit-service-account",
                })

    return findings


