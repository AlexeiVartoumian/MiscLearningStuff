from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()

class Conversation(Base):
    __tablename__ = "conversations"

    id = Column(String, primary_key=True, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    message_pairs = relationship("MessagePair", back_populates="conversation")

class MessagePair(Base):
    __tablename__ = "message_pairs"

    id = Column(Integer, primary_key=True, index=True)
    conversation_id = Column(String, ForeignKey("conversations.id"))
    human_message = Column(String)
    ai_message = Column(String)
    timestamp = Column(DateTime, default=datetime.utcnow)

    conversation = relationship("Conversation", back_populates="message_pairs")
# from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
# from sqlalchemy.orm import relationship
# from sqlalchemy.ext.declarative import declarative_base
# from datetime import datetime

# Base = declarative_base()

# class User(Base):
#     __tablename__ = "users"

#     user_id = Column(Integer, primary_key=True, index=True)
#     username = Column(String, unique=True, index=True)
#     email = Column(String, unique=True, index=True)
#     created_at = Column(DateTime(timezone=True),  default=datetime.utcnow)

# class Message(Base):
#     __tablename__ = "messages"

#     message_id = Column(Integer, primary_key=True, index=True)
#     conversation_id = Column(Integer, ForeignKey("conversations.conversation_id"))
#     sender_id = Column(Integer, ForeignKey("users.user_id"))
#     content = Column(String)
#     timestamp = Column(DateTime, default=datetime.utcnow)

#     conversation = relationship("Conversation", back_populates="messages")
#     sender = relationship("User")

# class Conversation(Base):
#     __tablename__ = "conversations"

#     conversation_id = Column(Integer, primary_key=True, index=True)
#     created_at = Column(DateTime, default=datetime.utcnow)

#     messages = relationship("Message", back_populates="conversation")
#     participants = relationship("User", secondary="conversation_participants")

# class ConversationParticipant(Base):
#     __tablename__ = "conversation_participants"

#     conversation_id = Column(Integer, ForeignKey("conversations.conversation_id"), primary_key=True)
#     user_id = Column(Integer, ForeignKey("users.user_id"), primary_key=True)

#------------------------------------------------------------------------------------------------








# from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
# from sqlalchemy.orm import relationship
# from sqlalchemy.ext.declarative import declarative_base
# from datetime import datetime

# Base = declarative_base()

# class User(Base):
#     __tablename__ = "users"

#     user_id = Column(Integer, primary_key=True, index=True)
#     username = Column(String, unique=True, index=True)
#     email = Column(String, unique=True, index=True)
#     created_at = Column(DateTime, default=datetime.utcnow)

# class Message(Base):
#     __tablename__ = "messages"

#     message_id = Column(Integer, primary_key=True, index=True)
#     conversation_id = Column(Integer, ForeignKey("conversations.conversation_id"))
#     sender_id = Column(Integer, ForeignKey("users.user_id"))
#     content = Column(String)
#     timestamp = Column(DateTime, default=datetime.utcnow)

#     conversation = relationship("Conversation", back_populates="messages")
#     sender = relationship("User")

# class Conversation(Base):
#     __tablename__ = "conversations"

#     conversation_id = Column(Integer, primary_key=True, index=True)
#     created_at = Column(DateTime, default=datetime.utcnow)

#     messages = relationship("Message", back_populates="conversation")
#     participants = relationship("User", secondary="conversation_participants")

# class ConversationParticipant(Base):
#     __tablename__ = "conversation_participants"

#     conversation_id = Column(Integer, ForeignKey("conversations.conversation_id"), primary_key=True)
#     user_id = Column(Integer, ForeignKey("users.user_id"), primary_key=True)

#/--------------------------------------------------------------------------------------------------






# from sqlalchemy import Column , Integer , String
# from .database import Base

# class Book(Base):
#     __tablename__ = "books"

#     id = Column(Integer , primary_key = True, index=True)
#     title = Column(String, index = True)
#     author = Column(String, index=True)
#     description = Column(String)
    