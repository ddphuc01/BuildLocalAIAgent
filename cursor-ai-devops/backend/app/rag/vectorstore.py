from typing import List, Tuple

try:
    import chromadb  # type: ignore
except Exception:  # pragma: no cover - optional during bootstrap
    chromadb = None


class VectorStore:
    def __init__(self, collection_name: str = "devops-kb") -> None:
        self.collection_name = collection_name
        self.client = chromadb.Client() if chromadb else None
        self.collection = (
            self.client.get_or_create_collection(collection_name) if self.client else None
        )

    def add_documents(self, docs: List[Tuple[str, str]]) -> None:
        if not self.collection:
            return
        ids = [d[0] for d in docs]
        texts = [d[1] for d in docs]
        self.collection.add(ids=ids, documents=texts)

    def search(self, query: str, k: int = 5) -> List[str]:
        if not self.collection:
            return []
        res = self.collection.query(query_texts=[query], n_results=k)
        return (res.get("documents", [[]])[0]) if res else []


