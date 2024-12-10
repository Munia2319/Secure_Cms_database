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
# Procedure: `GetCurrentEnrolledCourses`

This procedure retrieves the list of courses currently enrolled by the logged-in student. If the logged-in user is not a student, an error message is returned.

---

## SQL Procedure Definition

```sql
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCurrentEnrolledCourses`()
BEGIN
    DECLARE currentRole VARCHAR(50);
    DECLARE currentUserID INT;
    DECLARE currentEmail VARCHAR(255);

    -- Extract the email of the current user
    SELECT SUBSTRING_INDEX(USER(), '@', 1) INTO currentEmail;

    -- Fetch the role and UserID of the current user
    SELECT Role, UserID INTO currentRole, currentUserID
    FROM users
    WHERE Email = USER();

    -- Check if the current user is a student
    IF currentRole = 'Student' THEN
        SELECT
            e.EnrollmentID,
            u.Name AS StudentName,
            c.CourseName
        FROM
            enrollment e
        JOIN
            courses c ON e.CourseID = c.CourseID
        JOIN
            users u ON e.StudentID = u.UserID
        WHERE
            e.StudentID = currentUserID;
    ELSE
        -- If the user is not a student, return an error message
        SELECT 'You are not authorized to view enrolled courses.' AS Message;
    END IF;
END$$

DELIMITER ;
```
## How to Call the Procedure

### Syntax:
```sql
CALL GetCurrentEnrolledCourses();
```
# Procedure: `save_submission`

This procedure handles the submission of assignments or exams by a student. It validates the student's enrollment, encrypts the file path using a provided AES key, and updates or inserts the submission record.

---

## SQL Procedure Definition

```sql
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `save_submission`(
    IN assignment_id INT,
    IN exam_id INT,
    IN student_id INT,
    IN submission_type ENUM('Assignment', 'Exam'),
    IN file_path VARCHAR(255),
    IN aes_key VARCHAR(255)
)
BEGIN
    DECLARE course_id INT;
    DECLARE enrollment_check INT;
    DECLARE encrypted_file_path VARBINARY(255);

    -- Encrypt the file path
    SET encrypted_file_path = AES_ENCRYPT(file_path, aes_key);

    -- Determine the course based on the submission type
    IF submission_type = 'Assignment' THEN
        SELECT CourseID INTO course_id
        FROM assignments
        WHERE AssignmentID = assignment_id;
    ELSEIF submission_type = 'Exam' THEN
        SELECT CourseID INTO course_id
        FROM exams
        WHERE ExamID = exam_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Invalid submission type. Use "Assignment" or "Exam".';
    END IF;

    -- Validate enrollment
    SELECT COUNT(*) INTO enrollment_check
    FROM enrollment
    WHERE CourseID = course_id AND StudentID = student_id;

    IF enrollment_check = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: You are not enrolled in this course.';
    END IF;

    -- Handle submission based on the type
    IF submission_type = 'Assignment' THEN
        IF EXISTS (
            SELECT 1 FROM submissions
            WHERE AssignmentID = assignment_id AND StudentID = student_id
        ) THEN
            -- Update existing assignment submission
            UPDATE submissions
            SET FilePath = encrypted_file_path,
                SubmissionDate = CURDATE(),
                SubmissionTime = CURTIME()
            WHERE AssignmentID = assignment_id AND StudentID = student_id;
        ELSE
            -- Insert new assignment submission
            INSERT INTO submissions (
                SubmissionType, AssignmentID, ExamID, StudentID, FilePath, SubmissionDate, SubmissionTime
            )
            VALUES (
                submission_type, assignment_id, NULL, student_id, encrypted_file_path, CURDATE(), CURTIME()
            );
        END IF;
    ELSEIF submission_type = 'Exam' THEN
        IF EXISTS (
            SELECT 1 FROM submissions
            WHERE ExamID = exam_id AND StudentID = student_id
        ) THEN
            -- Update existing exam submission
            UPDATE submissions
            SET FilePath = encrypted_file_path,
                SubmissionDate = CURDATE(),
                SubmissionTime = CURTIME()
            WHERE ExamID = exam_id AND StudentID = student_id;
        ELSE
            -- Insert new exam submission
            INSERT INTO submissions (
                SubmissionType, AssignmentID, ExamID, StudentID, FilePath, SubmissionDate, SubmissionTime
            )
            VALUES (
                submission_type, NULL, exam_id, student_id, encrypted_file_path, CURDATE(), CURTIME()
            );
        END IF;
    END IF;

    -- Return success message
    SELECT 'Submission processed successfully.' AS Message;
END$$

DELIMITER ;
```
## How to Call the Procedure

### Syntax:
```sql
CALL save_submission(
    1, NULL, 1, 'Assignment', '/path/to/assignment.pdf', 'your_encryption_key'
);

```

# Procedure: `view_assignments`

This procedure retrieves the list of assignments visible to the logged-in user, depending on their role (Student or Professor). If the user is neither a student nor a professor, access is denied.

---

## SQL Procedure Definition

```sql
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `view_assignments`()
BEGIN
    DECLARE current_user_id INT;
    DECLARE current_user_role VARCHAR(20);
    DECLARE assignment_count INT;

    -- Fetch the current user's ID and role
    SELECT UserID, Role INTO current_user_id, current_user_role
    FROM Users
    WHERE Email = USER();

    -- Check the role of the user
    IF current_user_role = 'Student' THEN
        -- Count the assignments for the student's enrolled courses
        SELECT COUNT(*) INTO assignment_count
        FROM assignments a
        JOIN enrollment e ON a.CourseID = e.CourseID
        WHERE e.StudentID = current_user_id;

        -- Retrieve assignments if available
        IF assignment_count > 0 THEN
            SELECT a.AssignmentID, a.CourseID, c.CourseName, a.FilePath, a.UploadedDate, a.Deadline
            FROM assignments a
            JOIN enrollment e ON a.CourseID = e.CourseID
            JOIN Courses c ON a.CourseID = c.CourseID
            WHERE e.StudentID = current_user_id;
        ELSE
            SELECT 'You are not enrolled in any courses with assignments.' AS ErrorMessage;
        END IF;

    ELSEIF current_user_role = 'Professor' THEN
        -- Count the assignments for the professor's courses
        SELECT COUNT(*) INTO assignment_count
        FROM assignments a
        JOIN Courses c ON a.CourseID = c.CourseID
        WHERE c.ProfessorID = current_user_id;

        -- Retrieve assignments if available
        IF assignment_count > 0 THEN
            SELECT a.Assignment

```
## How to Call the Procedure

### Syntax:
```sql
CALL view_assignments();

```
# Procedure: `view_exam_file`

This procedure retrieves the file paths of exams for students and professors. It decrypts the file paths using a predefined AES encryption key and restricts access based on the user's role.

---

## SQL Procedure Definition

```sql
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `view_exam_file`()
BEGIN
    DECLARE current_user_id INT;
    DECLARE current_user_role VARCHAR(20);
    DECLARE decryption_key TEXT DEFAULT 'your_encryption_key';

    -- Retrieve the current user's ID and role
    SELECT UserID, Role INTO current_user_id, current_user_role
    FROM Users
    WHERE Email = USER();

    -- Role-based access control
    IF current_user_id IS NOT NULL AND current_user_role = 'Student' THEN
        -- Students can view exams only after the scheduled date
        SELECT CAST(AES_DECRYPT(e.FilePath, decryption_key) AS CHAR) AS DecryptedFilePath
        FROM Exams e
        JOIN enrollment en ON e.CourseID = en.CourseID
        WHERE en.StudentID = current_user_id
          AND e.ScheduledDate <= CURDATE();

    ELSEIF current_user_id IS NOT NULL AND current_user_role = 'Professor' THEN
        -- Professors can view exams for the courses they teach
        SELECT CAST(AES_DECRYPT(e.FilePath, decryption_key) AS CHAR) AS DecryptedFilePath
        FROM Exams e
        JOIN Courses c ON e.CourseID = c.CourseID
        WHERE c.ProfessorID = current_user_id;

    ELSE
        -- Access denied for other roles
        SELECT 'Access denied: Only students and professors can view exams.' AS ErrorMessage;
    END IF;
END$$

DELIMITER ;

```
## How to Call the Procedure

### Syntax:
```sql
CALL view_exam_file();
```
# Procedure: `view_grades`

This procedure retrieves grades for the logged-in user based on their role (Student, Professor, or Secretary). Each role has specific access privileges to view grades.

---

## SQL Procedure Definition

```sql
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `view_grades`()
BEGIN
    DECLARE current_user_id INT;
    DECLARE current_user_role VARCHAR(20);

    -- Fetch the current user's ID and role
    SELECT UserID, Role INTO current_user_id, current_user_role
    FROM Users
    WHERE Email = USER();

    -- Role-based access to grades
    IF current_user_role = 'Student' THEN
        -- Students can view their own grades
        SELECT
            g.GradeID,
            c.CourseName,
            CAST(AES_DECRYPT(g.Grade, 'encryption_key') AS CHAR) AS DecryptedGrade
        FROM Grades g
        JOIN Courses c ON g.CourseID = c.CourseID
        WHERE g.StudentID = current_user_id;

    ELSEIF current_user_role = 'Secretary' THEN
        -- Secretaries can view grades for all students
        SELECT
            g.GradeID,
            u.Name AS StudentName,
            c.CourseName,
            CAST(AES_DECRYPT(g.Grade, 'encryption_key') AS CHAR) AS DecryptedGrade
        FROM Grades g
        JOIN Users u ON g.StudentID = u.UserID
        JOIN Courses c ON g.CourseID = c.CourseID;

    ELSEIF current_user_role = 'Professor' THEN
        -- Professors can view grades for students in their courses
        SELECT
            g.GradeID,
            u.Name AS StudentName,
            c.CourseName,
            CAST(AES_DECRYPT(g.Grade, 'encryption_key') AS CHAR) AS DecryptedGrade
        FROM Grades g
        JOIN Users u ON g.StudentID = u.UserID
        JOIN Courses c ON g.CourseID = c.CourseID
        WHERE c.ProfessorID = current_user_id;

    ELSE
        -- Access denied for other roles
        SELECT 'Access denied: Only students, professors, and secretaries can view grades.' AS ErrorMessage;
    END IF;
END$$

DELIMITER ;

```
## How to Call the Procedure

### Syntax:
```sql
CALL view_grades();
```
# Procedure: `view_my_submitted_files`

This procedure allows a logged-in student to view their submitted files, including assignments and exams. The file paths are decrypted using a provided AES decryption key.

---

## SQL Procedure Definition

```sql
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `view_my_submitted_files`(
    IN aes_key VARCHAR(255)
)
BEGIN
    DECLARE current_student_id INT;

    -- Fetch the current user's ID
    SELECT UserID INTO current_student_id
    FROM Users
    WHERE Email = USER();

    -- Validate that the current user is a student
    IF current_student_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: You are not authorized to view submissions.';
    END IF;

    -- Retrieve and decrypt submitted files for the student
    SELECT
        SubmissionID,
        SubmissionType,
        AssignmentID,
        ExamID,
        CONVERT(AES_DECRYPT(FilePath, aes_key) USING utf8) AS DecryptedFilePath,
        SubmissionDate,
        SubmissionTime
    FROM submissions
    WHERE StudentID = current_student_id;
END$$

DELIMITER ;

```
## How to Call the Procedure

### Syntax:
```sql
CALL view_my_submitted_files('your_aes_key');
```
# Procedure: `manage_grades`

This procedure allows a professor to manage grades for students in the courses they teach. It supports three actions: `View`, `Insert`, and `Update`.

---

## SQL Procedure Definition

```sql
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `manage_grades`(
    IN professor_id INT,
    IN course_id INT,
    IN action VARCHAR(20),
    IN student_id INT,
    IN grade VARCHAR(2)
)
BEGIN
    -- Check if the professor is teaching the course
    IF EXISTS (
        SELECT 1
        FROM Courses
        WHERE CourseID = course_id AND ProfessorID = professor_id
    ) THEN
        IF action = 'View' THEN
            -- View grades for the course
            SELECT
                g.GradeID,
                g.StudentID,
                u.Name AS StudentName,
                c.CourseName,
                AES_DECRYPT(g.Grade, 'encryption_key') AS Grade
            FROM Grades g
            JOIN Users u ON g.StudentID = u.UserID
            JOIN Courses c ON g.CourseID = c.CourseID
            WHERE g.CourseID = course_id;

        ELSEIF action = 'Insert' THEN
            -- Insert or update a grade
            IF EXISTS (
                SELECT 1
                FROM Grades
                WHERE CourseID = course_id AND StudentID = student_id
            ) THEN
                -- Update grade if it already exists
                UPDATE Grades
                SET Grade = AES_ENCRYPT(grade, 'encryption_key')
                WHERE CourseID = course_id AND StudentID = student_id;
            ELSE
                -- Insert new grade
                IF student_id IS NOT NULL AND grade IS NOT NULL THEN
                    INSERT INTO Grades (StudentID, CourseID, Grade, ProfessorID)
                    VALUES (student_id, course_id, AES_ENCRYPT(grade, 'encryption_key'), professor_id);
                ELSE
                    SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Student ID and Grade are required for Insert action.';
                END IF;
            END IF;

        ELSEIF action = 'Update' THEN
            -- Update a grade
            IF student_id IS NOT NULL AND grade IS NOT NULL THEN
                UPDATE Grades
                SET Grade = AES_ENCRYPT(grade, 'encryption_key')
                WHERE StudentID = student_id AND CourseID = course_id;
            ELSE
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Student ID and Grade are required for Update action.';
            END IF;

        ELSE
            -- Invalid action
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid action. Use "View", "Insert", or "Update".';
        END IF;

    ELSE
        -- Access denied if the professor is not teaching the course
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Access denied: You are not teaching this course.';
    END IF;
END$$

DELIMITER ;

```
## How to Call the Procedure

### Syntax:
```sql
CALL manage_grades(professor_id, course_id, action, student_id, grade);
action=Insert/Update
```
# Procedure: `upload_content`

This procedure allows a professor to upload or update exam-related content for a course they are authorized to teach. Content such as exam schedules, deadlines, and file paths are stored securely using encryption.

---

## SQL Procedure Definition

```sql
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `upload_content`(
    IN p_ExamID INT,
    IN p_CourseID INT,
    IN p_ProfessorID INT,
    IN p_ScheduledDate DATE,
    IN p_ExamTime TIME,
    IN p_Deadline DATETIME,
    IN p_FilePath VARCHAR(255),
    IN p_EncryptionKey TEXT
)
BEGIN
    -- Verify professor's authorization for the course
    IF EXISTS (
        SELECT 1
        FROM Courses
        WHERE CourseID = p_CourseID AND ProfessorID = p_ProfessorID
    ) THEN
        -- Check if the exam already exists
        IF EXISTS (
            SELECT 1
            FROM Exams
            WHERE ExamID = p_ExamID
        ) THEN
            -- Update existing exam content
            UPDATE Exams
            SET
                ScheduledDate = p_ScheduledDate,
                ExamTime = p_ExamTime,
                Deadline = p_Deadline,
                FilePath = AES_ENCRYPT(p_FilePath, p_EncryptionKey)
            WHERE ExamID = p_ExamID;
        ELSE
            -- Insert new exam content
            INSERT INTO Exams (ExamID, CourseID, ScheduledDate, ExamTime, Deadline, FilePath)
            VALUES (
                p_ExamID,
                p_CourseID,
                p_ScheduledDate,
                p_ExamTime,
                p_Deadline,
                AES_ENCRYPT(p_FilePath, p_EncryptionKey)
            );
        END IF;
    ELSE
        -- Access denied for unauthorized professors
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Professor is not authorized to upload or update content for this course.';
    END IF;
END$$

DELIMITER ;

```
## How to Call the Procedure

### Syntax:
```sql
CALL upload_content(p_ExamID, p_CourseID, p_ProfessorID, p_ScheduledDate, p_ExamTime, p_Deadline, p_FilePath, p_EncryptionKey);
```
# Procedure: `view_grades_with_students`

This procedure allows a secretary to view all student grades across courses. It decrypts the grades for readability and provides details about students and their enrolled courses.

---

## SQL Procedure Definition

```sql
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `view_grades_with_students`()
BEGIN
    DECLARE current_user_id INT;
    DECLARE current_user_role VARCHAR(20);

    -- Retrieve the current user's ID and role
    SELECT UserID, Role INTO current_user_id, current_user_role
    FROM Users
    WHERE Email = USER();

    -- Allow access only if the current user is a secretary
    IF current_user_role = 'Secretary' THEN
        -- Fetch all grades along with student and course details
        SELECT
            g.GradeID,
            g.StudentID,
            u.Name AS StudentName,
            g.CourseID,
            c.CourseName,
            CAST(AES_DECRYPT(g.Grade, 'encryption_key') AS CHAR) AS DecryptedGrade
        FROM grades g
        JOIN Courses c ON g.CourseID = c.CourseID
        JOIN Users u ON g.StudentID = u.UserID;
    ELSE
        -- Deny access for unauthorized users
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Access denied: Only secretaries can view grades.';
    END IF;
END$$

DELIMITER ;

```
## How to Call the Procedure

### Syntax:
```sql
CALL view_grades_with_students();
```







