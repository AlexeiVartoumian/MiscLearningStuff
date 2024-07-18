from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from database import engine,get_db
import models
import schemas
import uuid

from models import Conversation, MessagePair


from schemas import ConversationSchema, MessagePairSchema


from database import SessionLocal, engine


models.Base.metadata.create_all(bind = engine)
app = FastAPI()


@app.post("/conversations/", response_model=ConversationSchema)
def create_conversation(db: Session = Depends(get_db)):
    new_conversation = Conversation(id=str(uuid.uuid4()))
    db.add(new_conversation)
    db.commit()
    db.refresh(new_conversation)
    return new_conversation

@app.get("/conversations/{conversation_id}", response_model=ConversationSchema)
def get_conversation(conversation_id: str, db: Session = Depends(get_db)):
    conversation = db.query(Conversation).filter(Conversation.id == conversation_id).first()
    if conversation is None:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return conversation

@app.post("/conversations/{conversation_id}/messages/", response_model=MessagePairSchema)
def add_message_pair(conversation_id: str, human_message: str, ai_message: str, db: Session = Depends(get_db)):
    conversation = db.query(Conversation).filter(Conversation.id == conversation_id).first()
    if conversation is None:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    new_message_pair = MessagePair(
        conversation_id=conversation_id,
        human_message=human_message,
        ai_message=ai_message
    )
    db.add(new_message_pair)
    db.commit()
    db.refresh(new_message_pair)
    return new_message_pair



#alex creds for git 
# vartouma-at-992382660679
# Cja6UZx2FkjqUSm4F8aoK7QON5sewNQ9UQyb/Jpf7GAOD6xFsFyOoHsklEo=











# # User endpoints
# @app.post("/users/", response_model=schemas.UserSchema)
# def create_user(user: schemas.UserSchema, db: Session = Depends(get_db)):
#     db_user = models.User(**user.dict())
#     db.add(db_user)
#     db.commit()
#     db.refresh(db_user)
#     return schemas.UserSchema.from_orm(db_user)

# #testing if all user exist w.  curl "http://localhost:8000/users/"
# @app.get("/users/", response_model = List[schemas.UserSchema])
# def get_users(db: Session = Depends(get_db)):
#     db_users = db.query(models.User).all()
#     if db_users is None:
#         raise HTTPException(status_code=404, detail="No users found")
#     return db_users


# @app.get("/users/{user_id}", response_model=schemas.UserSchema)
# def read_user(user_id: int, db: Session = Depends(get_db)):
#     db_user = db.query(models.User).filter(models.User.user_id == user_id).first()
#     if db_user is None:
#         raise HTTPException(status_code=404, detail="User not found")
#     return schemas.UserSchema.from_orm(db_user)

# # Conversation endpoints
# @app.post("/conversations/", response_model=schemas.ConversationSchema)
# def create_conversation(conversation: schemas.ConversationSchema, db: Session = Depends(get_db)):
#     db_conversation = models.Conversation(**conversation.dict(exclude={"participants", "messages"}))
#     for user_id in conversation.participants:
#         participant = db.query(models.User).filter(models.User.user_id == user_id).first()
#         if participant:
#             db_conversation.participants.append(participant)
#     db.add(db_conversation)
#     db.commit()
#     db.refresh(db_conversation)
#     return db_conversation

# @app.get("/conversations/{conversation_id}", response_model=schemas.ConversationSchema)
# def read_conversation(conversation_id: int, db: Session = Depends(get_db)):
#     db_conversation = db.query(models.Conversation).filter(models.Conversation.conversation_id == conversation_id).first
#     if db_conversation is None:
#         raise HTTPException(status_code=404, detail="Conversation not found")
#     return db_conversation

# # Message endpoints
# @app.post("/messages/", response_model=schemas.MessageSchema)
# def create_message(message: schemas.MessageSchema, db: Session = Depends(get_db)):
#     db_message = models.Message(**message.dict())
#     db.add(db_message)
#     db.commit()
#     db.refresh(db_message)
#     return db_message

# @app.get("/messages/{message_id}", response_model=schemas.MessageSchema)
# def read_message(message_id: int, db: Session = Depends(get_db)):
#     db_message = db.query(models.Message).filter(models.Message.message_id == message_id).first()
#     if db_message is None:
#                 raise HTTPException(status_code=404, detail="Message not found")
#     return db_message









# from fastapi import FastAPI, Depends, HTTPException
# from sqlalchemy.orm import Session
# from typing import List

# from database import get_db
# import models
# import schemas

# app = FastAPI()

# # User endpoints
# @app.post("/users/", response_model=schemas.UserSchema)
# def create_user(user: schemas.UserSchema, db: Session = Depends(get_db)):
#     db_user = models.User(**user.dict())
#     db.add(db_user)
#     db.commit()
#     db.refresh(db_user)
#     return db_user

# @app.get("/users/{user_id}", response_model=schemas.UserSchema)
# def read_user(user_id: int, db: Session = Depends(get_db)):
#     db_user = db.query(models.User).filter(models.User.user_id == user_id).first()
#     if db_user is None:
#         raise HTTPException(status_code=404, detail="User not found")
#     return db_user

# Conversation endpoints
# @app.post("/conversations/", response_model=schemas.ConversationSchema)
# def create_conversation(conversation: schemas.ConversationSchema, db: Session = Depends(get_db)):
#     db_conversation = models.Conversation(**conversation.dict(exclude={"participants", "messages"}))
#     for user_id in conversation.participants:
#         participant = db.query(models.User).filter(models.User.user_id == user_id).first()
#         if participant:
#             db_conversation.participants.append(participant)
#     db.add(db_conversation)
#     db.commit()
#     db.refresh(db_conversation)
#     return db_conversation

# @app.get("/conversations/{conversation_id}", response_model=schemas.ConversationSchema)
# def read_conversation(conversation_id: int, db: Session = Depends(get_db)):
#     db_conversation = db.query(models.Conversation).filter(models.Conversation.conversation_id == conversation_id).first()
#     if db_conversation is None:
#         raise HTTPException(status_code=404, detail="Conversation not found")
#     return db_conversation

# # Message endpoints
# @app.post("/messages/", response_model=schemas.MessageSchema)
# def create_message(message: schemas.MessageSchema, db: Session = Depends(get_db)):
#     db_message = models.Message(**message.dict())
#     db.add(db_message)
#     db.commit()
#     db.refresh(db_message)
#     return db_message

# @app.get("/messages/{message_id}", response_model=schemas.MessageSchema)
# def read_message(message_id: int, db: Session = Depends(get_db)):
#     db_message = db.query(models.Message).filter(models.Message.message_id == message_id).first()
#     if db_message is None:
#         raise HTTPException(status_code=404, detail="Message not found")
#     return db_message
# from fastapi import FastAPI , Depends , HTTPException
# from sqlalchemy.orm import Session
# from . import models ,schemas
# from .database import engine, get_db


# models.Base.metadata.create_all(bind = engine)

# app = FastAPI()
# @app.get("/")
# def read_root():
#     return {"Hello": "World"}
# @app.post("/books/", response_model = schemas.Book)
# def create_book(book: schemas.BookCreate, db:Session = Depends(get_db)):
#     db_book = models.Book(**book.dict())
#     db.add(db_book)
#     db.commit()
#     db.refresh(db_book)
#     return db_book

# @app.get("/books/", response_model = list[schemas.Book])
# def read_books(skip: int = 0, limit: int = 100 , db: Session = Depends(get_db)):
#     books = db.query(models.Book).offset(skip).limit(limit).all()
#     return books

# @app.get("/books/{book_id}", response_model = schemas.Book)
# def read_book(book_id:int , db: Session = Depends(get_db)):
#     book = db.query(models.Book).filter(models.Book.id == book.id).first()
#     if book is None:
#         raise HTTPException(status_code=404, detail="Book not found")
#     return book