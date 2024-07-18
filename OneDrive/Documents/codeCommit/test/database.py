from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# DATABASE_URL = "postgresql://postgres:nomura123@13.42.53.37/database_name"

#DATABASE_URL = "postgresql://postgres:postgres123@10.0.2.71:5432/chat"

DATABASE_URL = "postgresql://postgres:postgres123@10.0.2.71:5432/ai_convo"
engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(autocommit = False, autoflush=False,bind = engine )

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
