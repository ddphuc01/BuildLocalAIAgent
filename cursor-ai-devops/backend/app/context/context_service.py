from pathlib import Path
from typing import Dict, Any
from git import Repo, InvalidGitRepositoryError


class ProjectContextService:
    def __init__(self, workspace: str) -> None:
        self.workspace = Path(workspace)

    def summarize(self) -> Dict[str, Any]:
        summary: Dict[str, Any] = {"workspace": str(self.workspace), "git": {}}
        try:
            repo = Repo(self.workspace)
            summary["git"] = {
                "active_branch": str(repo.active_branch) if not repo.head.is_detached else "detached",
                "dirty": repo.is_dirty(),
                "remotes": [str(r) for r in repo.remotes],
            }
        except InvalidGitRepositoryError:
            summary["git"] = {"status": "not_a_git_repo"}
        return summary


