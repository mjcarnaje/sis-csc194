from flask import Flask, render_template

app = Flask(__name__)

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/courses")
def courses():
    return render_template("courses.html")

@app.route("/courses/add")
def add_course():
    return render_template("add_course.html")

@app.route("/courses/edit/<int:id>")
def edit_course(id):
    return render_template("edit_course.html", course_id=id)

@app.route("/courses/<int:id>")
def course(id):
    return render_template("view_course.html", course_id=id)

@app.route("/courses/<int:id>/add")
def add_student_in_course(id):
    return render_template("add_student.html", course_id=id)

@app.route("/students/add")
def add_student():
    return render_template("add_student.html")

@app.route("/students/edit/<int:id>")
def edit_student(id):
    return render_template("edit_student.html", student_id=id)

@app.route("/students/<int:id>")
def student(id):
    return render_template("view_student.html", student_id=id)

@app.route("/students")
def students():
    return render_template("students.html")