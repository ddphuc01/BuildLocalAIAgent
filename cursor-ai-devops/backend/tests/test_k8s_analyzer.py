from app.integrations.k8s.analyzer import analyze_manifest


def test_analyzer_flags_latest_and_no_resources():
    manifest = """
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo
spec:
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
      - name: c
        image: nginx:latest
    """
    findings = analyze_manifest(manifest)
    rules = {f["rule"] for f in findings}
    assert "image-tag-not-latest" in rules
    assert "resources-requests-limits-required" in rules


