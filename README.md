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


# Procedure: `get_user_data`

This procedure retrieves user data from the `users` table, including a decrypted version of the user's password. The `AES_DECRYPT` function is used to decrypt the stored password hash using a predefined encryption key.

## SQL Procedure Definition

```sql
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_data`()
BEGIN
    SELECT
        UserID,
        Role,
        Name,
        Email,
        CAST(AES_DECRYPT(PasswordHash, 'encryption_key') AS CHAR) AS DecryptedPassword
    FROM users
    WHERE Email = USER();
END$$

DELIMITER ;
```
## How to Call the Procedure

### Syntax:
```sql
CALL get_user_data();
```
# Procedure: `GetAvailableCourses`

This procedure retrieves all available courses from the `courses` table.

---

## SQL Procedure Definition

```sql
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAvailableCourses`()
BEGIN
    SELECT * FROM courses;
END$$

DELIMITER ;
```
## How to Call the Procedure

### Syntax:
```sql
CALL GetAvailableCourses();
```
# Procedure: `enroll_in_course`

This procedure allows a student to enroll in a course by providing either the course ID or course name. The procedure checks the student's eligibility and ensures the course exists before enrolling.

---

## SQL Procedure Definition

```sql
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `enroll_in_course`(IN course_identifier VARCHAR(255))
BEGIN
    DECLARE current_user_id INT;
    DECLARE current_user_role VARCHAR(20);
    DECLARE course_id INT;
    DECLARE course_exists BOOLEAN;

    -- Fetch current user details
    SELECT UserID, Role INTO current_user_id, current_user_role
    FROM users
    WHERE Email = USER();

    -- Determine course ID from the input (CourseID or CourseName)
    IF course_identifier REGEXP '^[0-9]+$' THEN
        SET course_id = CAST(course_identifier AS UNSIGNED);
    ELSE
        SELECT CourseID INTO course_id
        FROM courses
        WHERE CourseName = course_identifier;
    END IF;

    -- Check if the course exists
    SELECT COUNT(*) > 0 INTO course_exists
    FROM courses
    WHERE CourseID = course_id;

    -- Verify if the user is a student and proceed with enrollment
    IF current_user_id IS NOT NULL AND current_user_role = 'Student' THEN
        IF course_exists THEN
            IF NOT EXISTS (
                SELECT 1
                FROM enrollment
                WHERE StudentID = current_user_id AND CourseID = course_id
            ) THEN
                INSERT INTO enrollment (StudentID, CourseID)
                VALUES (current_user_id, course_id);

                SELECT 'Enrollment successful.' AS Message;
            ELSE
                SELECT 'You are already enrolled in this course.' AS ErrorMessage;
            END IF;
        ELSE
            SELECT 'Enrollment failed: The specified course does not exist.' AS ErrorMessage;
        END IF;
    ELSE
        SELECT 'Enrollment failed: You must be a student to enroll in a course.' AS ErrorMessage;
    END IF;
END$$

DELIMITER ;
```
## How to Call the Procedure

### Syntax:
```sql
CALL enroll_in_course('1');
CALL enroll_in_course('Database Security');

```


