from fastapi import FastAPI , Depends , HTTPException
from sqlalchemy.orm import Session
from . import models ,schemas
from .database import engine, get_db


models.Base.metadata.create_all(bind = engine)

app = FastAPI()
@app.get("/")
def read_root():
    return {"Hello": "World"}
@app.post("/books/", response_model = schemas.Book)
def create_book(book: schemas.BookCreate, db:Session = Depends(get_db)):
    db_book = models.Book(**book.dict())
    db.add(db_book)
    db.commit()
    db.refresh(db_book)
    return db_book

@app.get("/books/", response_model = list[schemas.Book])
def read_books(skip: int = 0, limit: int = 100 , db: Session = Depends(get_db)):
    books = db.query(models.Book).offset(skip).limit(limit).all()
    return books

@app.get("/books/{book_id}", response_model = schemas.Book)
def read_book(book_id:int , db: Session = Depends(get_db)):
    book = db.query(models.Book).filter(models.Book.id == book.id).first()
    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    return book