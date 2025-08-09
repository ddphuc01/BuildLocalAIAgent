from prometheus_client import Counter, Histogram

http_requests_total = Counter("http_requests_total", "Total HTTP requests", ["method", "path", "status"])
llm_tokens_total = Counter("llm_tokens_total", "Total LLM tokens used", ["provider"])
llm_latency_seconds = Histogram("llm_latency_seconds", "LLM call latency", ["provider"])


