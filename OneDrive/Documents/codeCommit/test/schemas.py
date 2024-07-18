from pydantic import BaseModel, Field
from datetime import datetime
from typing import List

class MessagePairSchema(BaseModel):
    human_message: str = Field(..., description="The message from the human")
    ai_message: str = Field(..., description="The response from the AI")
    timestamp: datetime = Field(..., description="The timestamp when the message pair was created")

    class Config:
        orm_mode = True

class ConversationSchema(BaseModel):
    id: str = Field(..., description="The unique identifier for the conversation")
    created_at: datetime = Field(..., description="The timestamp when the conversation was created")
    message_pairs: List[MessagePairSchema] = Field(..., description="The list of human-AI message pairs in the conversation")

    class Config:
        orm_mode = True


# from pydantic import BaseModel, Field, EmailStr
# from datetime import datetime
# from typing import List

# class UserSchema(BaseModel):
#     user_id: int = Field(..., description="The unique identifier for a user")
#     username: str = Field(..., description="The username for a user")
#     email: EmailStr = Field(..., description="The email address for a user")
#     created_at: datetime = Field(..., description="The timestamp when the user was created")

#     class Config:
#         orm_mode = True

# class MessageSchema(BaseModel):
#     message_id: int = Field(..., description= "The unique identifier for a message")
#     conversation_id: str = Field(..., description= "The id of the conversation this message belongs to")
#     sender_id: int = Field(..., description= "The id of the user of sent the message")
#     content: str = Field(..., description= "The content of the message")
#     timestamp: datetime = Field(..., description = "the timestamp when the messge was sent")

#     class Config:
#         orm_mode = True

# class ConversationSchema(BaseModel):
#     conversation_id: int = Field(..., description= "The unique identifier for a conversation")
#     participants: List[int] = Field(..., description= "The list of user Ids participating in the conversation")
#     created_at: datetime = Field(..., description= "The timestamp when the conversation was created")
#     messages: List[MessageSchema] = Field(..., description= "The list of messages in the conversation")

#     class Config:
#         orm_mode = True










#/---------------------------------------------------------------------------------
# from pydantic import BaseModel, Field, EmailStr
# from datetime import datetime
# from typing import List


# class UserSchema(BaseModel):
#     user_id: int = Field(..., description="The unique identifier for a user")
#     username: str = Field(..., description="The username for a user")
#     email: EmailStr = Field(..., description="The email address for a user")
#     created_at: datetime = Field(..., description="The timestamp when the user was created")


# class MessageSchema(BaseModel):
#     message_id: int = Field(..., description="The unique identifier for a message")
#     conversation_id: int = Field(..., description="The id of the conversation this message belongs to")
#     sender_id: int = Field(..., description="The id of the user who sent the message")
#     content: str = Field(..., description="The content of the message")
#     timestamp: datetime = Field(..., description="The timestamp when the message was sent")


# class ConversationSchema(BaseModel):
#     conversation_id: int = Field(..., description="The unique identifier for a conversation")
#     participants: List[int] = Field(..., description="The list of user Ids participating in the conversation")
#     created_at: datetime = Field(..., description="The timestamp when the conversation was created")
#     messages: List[MessageSchema] = Field(..., description="The list of messages in the conversation")

# from pydantic import BaseModel

# class BookBase(BaseModel):
#     title: str
#     author : str
#     description: str | None = None

# class BookCreate(BookBase):
#     pass

# class Book(BookBase):
#     id:int

#     class Config:
#         orm_mode = True