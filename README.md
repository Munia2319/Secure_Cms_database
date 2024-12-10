# Secure_Cms_database

# Database Schema and Relationships

## Table Relationships and Interactions

### 1. `users` Table
- **Primary Key**: `UserID`
- **Purpose**: Stores data for all types of users (students, professors, secretaries, and IT administrators).
- **Relationships**:
  - Referenced as a foreign key in other tables to link roles and identities of users.

### 2. `enrollment` Table
- **Primary Key**: `EnrollmentID`
- **Foreign Keys**:
  - `StudentID` references `users.UserID` (students enroll in courses).
  - `CourseID` references `courses.CourseID`.
- **Purpose**: Establishes a many-to-many relationship between students and courses.

### 3. `courses` Table
- **Primary Key**: `CourseID`
- **Foreign Key**: `ProfessorID` references `users.UserID` (professors teach courses).
- **Purpose**: Stores details of courses offered, linked to professors.

### 4. `assignments` Table
- **Primary Key**: `AssignmentID`
- **Foreign Keys**:
  - `CourseID` references `courses.CourseID` (assignments belong to courses).
  - `UploadedBy` references `users.UserID` (professors upload assignments).
- **Purpose**: Contains information about assignments for specific courses.

### 5. `grades` Table
- **Primary Key**: `GradeID`
- **Foreign Keys**:
  - `StudentID` references `users.UserID` (grades are assigned to students).
  - `CourseID` references `courses.CourseID` (grades belong to courses).
  - `ProfessorID` references `users.UserID` (professors assign grades).
- **Purpose**: Stores grades assigned by professors and accessible by students and secretaries.

### 6. `submissions` Table
- **Primary Key**: `SubmissionID`
- **Foreign Keys**:
  - `AssignmentID` references `assignments.AssignmentID` (submission links to assignments).
  - `ExamID` references `exams.ExamID` (if applicable, for exam submissions).
  - `StudentID` references `users.UserID` (students submit their work).
- **Purpose**: Tracks assignment and exam submissions by students.

### 7. `exams` Table
- **Primary Key**: `ExamID`
- **Foreign Key**: `CourseID` references `courses.CourseID` (exams belong to specific courses).
- **Purpose**: Stores details about exams. Students cannot view exams before the scheduled date and time.

---

## Relationships Between Tables

### One-to-Many Relationships
- **Professor to Courses**: A professor (`users`) teaches multiple courses (`courses`).
- **Course to Assignments/Exams**: A course (`courses`) can have many assignments (`assignments`) and exams (`exams`).
- **Student to Grades/Submissions**: A student (`users`) can have multiple grades (`grades`) and submissions (`submissions`).

### Many-to-Many Relationships
- **Students and Courses**: Students can enroll in multiple courses, and each course can have many students (via `enrollment` table).

### Foreign Key Communication
- `users.UserID` is referenced in `enrollment`, `grades`, `assignments`, and `submissions`.
- `courses.CourseID` is referenced in `assignments`, `grades`, `enrollment`, and `exams`.
- `assignments.AssignmentID` is referenced in `submissions`.
- `exams.ExamID` is referenced in `submissions`.

---

## Security and Visibility Logic

### Data Access
- **Encryption**: Sensitive data such as grades, submission files, exam files, and passwords are encrypted when stored in the database. When accessed, they are automatically decrypted for authorized users.
- **User Restrictions**: Each user can only view their own personal data (e.g., grades, exam files, and submissions).

### Assignments
- Professors upload assignments that are only visible to students enrolled in the corresponding course.
- Assignment submissions are private and cannot be viewed by other students.

### Exams
- Exam files are stored encrypted and remain invisible to students until the scheduled date and time.

### Grades
- Professors can add or update grades only for the courses they are teaching.
- Students can view only their own grades.
- Secretaries can access grades for all courses for administrative purposes.

### Role-Based Permissions
- **Students**: Can view enrolled courses, assignments, grades, and exams after the scheduled time. They can submit assignments privately.
- **Professors**: Can create and manage content (slides, assignments, exams) and assign grades only for the courses they teach.
- **Secretaries**: Can view all students' grades but cannot modify them.
- **IT Administrators**: Can manage the database but cannot access user-specific encrypted content.

### Enrollment Management
- Students can enroll in courses via the system. Enrollment links them to courses, enabling access to relevant assignments, exams, and grades.

---

This design ensures a structured, secure, and role-based content management system with clear rules for access and visibility. The use of encryption enhances security while maintaining user-specific access.
