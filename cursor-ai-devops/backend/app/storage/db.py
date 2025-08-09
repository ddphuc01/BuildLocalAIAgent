from typing import Optional
from sqlmodel import SQLModel, Field, create_engine, Session


class Conversation(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str


class Message(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    conversation_id: int
    role: str
    content: str


engine = create_engine("sqlite:///./app.db")


def init_db() -> None:
    SQLModel.metadata.create_all(engine)


def get_session() -> Session:
    return Session(engine)


