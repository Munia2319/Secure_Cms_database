-- MySQL dump 10.13  Distrib 8.0.40, for Win64 (x86_64)
--
-- Host: localhost    Database: Securecms
-- ------------------------------------------------------
-- Server version	8.0.40

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `assignments`
--

DROP TABLE IF EXISTS `assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assignments` (
  `AssignmentID` int NOT NULL AUTO_INCREMENT,
  `CourseID` int NOT NULL,
  `UploadedBy` int NOT NULL,
  `FilePath` varchar(255) NOT NULL,
  `UploadedDate` date NOT NULL,
  `Deadline` datetime NOT NULL DEFAULT '2024-12-31 23:59:59',
  PRIMARY KEY (`AssignmentID`),
  KEY `CourseID` (`CourseID`),
  KEY `UploadedBy` (`UploadedBy`),
  CONSTRAINT `assignments_ibfk_1` FOREIGN KEY (`CourseID`) REFERENCES `courses` (`CourseID`) ON DELETE CASCADE,
  CONSTRAINT `assignments_ibfk_2` FOREIGN KEY (`UploadedBy`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assignments`
--

LOCK TABLES `assignments` WRITE;
/*!40000 ALTER TABLE `assignments` DISABLE KEYS */;
INSERT INTO `assignments` VALUES (1,1,2,'/files/sample_assignment.pdf','2024-12-01','2024-12-31 23:59:59'),(2,1,2,'/files/new_assignment.pdf','2024-12-05','2024-12-15 23:59:59');
/*!40000 ALTER TABLE `assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `courses` (
  `CourseID` int NOT NULL AUTO_INCREMENT,
  `CourseName` varchar(100) NOT NULL,
  `ProfessorID` int DEFAULT NULL,
  PRIMARY KEY (`CourseID`),
  KEY `ProfessorID` (`ProfessorID`),
  CONSTRAINT `courses_ibfk_1` FOREIGN KEY (`ProfessorID`) REFERENCES `users` (`UserID`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courses`
--

LOCK TABLES `courses` WRITE;
/*!40000 ALTER TABLE `courses` DISABLE KEYS */;
INSERT INTO `courses` VALUES (1,'Database Security',2),(2,'Cryptography',2);
/*!40000 ALTER TABLE `courses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enrollment`
--

DROP TABLE IF EXISTS `enrollment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `enrollment` (
  `EnrollmentID` int NOT NULL AUTO_INCREMENT,
  `StudentID` int NOT NULL,
  `CourseID` int NOT NULL,
  PRIMARY KEY (`EnrollmentID`),
  KEY `StudentID` (`StudentID`),
  KEY `CourseID` (`CourseID`),
  CONSTRAINT `enrollment_ibfk_1` FOREIGN KEY (`StudentID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE,
  CONSTRAINT `enrollment_ibfk_2` FOREIGN KEY (`CourseID`) REFERENCES `courses` (`CourseID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enrollment`
--

LOCK TABLES `enrollment` WRITE;
/*!40000 ALTER TABLE `enrollment` DISABLE KEYS */;
INSERT INTO `enrollment` VALUES (1,1,1),(2,2,1),(3,5,2),(4,1,2);
/*!40000 ALTER TABLE `enrollment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exams`
--

DROP TABLE IF EXISTS `exams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exams` (
  `ExamID` int NOT NULL AUTO_INCREMENT,
  `CourseID` int NOT NULL,
  `ScheduledDate` date NOT NULL,
  `ExamTime` time NOT NULL,
  `Deadline` datetime DEFAULT NULL,
  `FilePath` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ExamID`),
  KEY `CourseID` (`CourseID`),
  CONSTRAINT `exams_ibfk_1` FOREIGN KEY (`CourseID`) REFERENCES `courses` (`CourseID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exams`
--

LOCK TABLES `exams` WRITE;
/*!40000 ALTER TABLE `exams` DISABLE KEYS */;
INSERT INTO `exams` VALUES (1,1,'2024-12-13','17:43:00','2024-12-13 20:43:00','/files/exam.pdf');
/*!40000 ALTER TABLE `exams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grades`
--

DROP TABLE IF EXISTS `grades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `grades` (
  `GradeID` int NOT NULL AUTO_INCREMENT,
  `StudentID` int NOT NULL,
  `CourseID` int NOT NULL,
  `ProfessorID` int NOT NULL,
  `Grade` char(1) DEFAULT NULL,
  PRIMARY KEY (`GradeID`),
  KEY `StudentID` (`StudentID`),
  KEY `CourseID` (`CourseID`),
  KEY `ProfessorID` (`ProfessorID`),
  CONSTRAINT `grades_ibfk_1` FOREIGN KEY (`StudentID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE,
  CONSTRAINT `grades_ibfk_2` FOREIGN KEY (`CourseID`) REFERENCES `courses` (`CourseID`) ON DELETE CASCADE,
  CONSTRAINT `grades_ibfk_3` FOREIGN KEY (`ProfessorID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grades`
--

LOCK TABLES `grades` WRITE;
/*!40000 ALTER TABLE `grades` DISABLE KEYS */;
INSERT INTO `grades` VALUES (1,1,1,2,'A'),(2,1,1,2,'A'),(3,2,1,2,'B'),(4,1,2,3,'A'),(5,5,2,3,'B');
/*!40000 ALTER TABLE `grades` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `restrictedgrades`
--

DROP TABLE IF EXISTS `restrictedgrades`;
/*!50001 DROP VIEW IF EXISTS `restrictedgrades`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `restrictedgrades` AS SELECT 
 1 AS `GradeID`,
 1 AS `StudentID`,
 1 AS `CourseID`,
 1 AS `ProfessorID`,
 1 AS `Grade`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `studentexamsview`
--

DROP TABLE IF EXISTS `studentexamsview`;
/*!50001 DROP VIEW IF EXISTS `studentexamsview`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `studentexamsview` AS SELECT 
 1 AS `ExamID`,
 1 AS `CourseID`,
 1 AS `CourseName`,
 1 AS `ScheduledDate`,
 1 AS `ExamTime`,
 1 AS `FilePath`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `submissions`
--

DROP TABLE IF EXISTS `submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `submissions` (
  `SubmissionID` int NOT NULL AUTO_INCREMENT,
  `SubmissionType` enum('Assignment','Exam') NOT NULL,
  `AssignmentID` int DEFAULT NULL,
  `ExamID` int DEFAULT NULL,
  `StudentID` int NOT NULL,
  `FilePath` varchar(255) NOT NULL,
  `SubmissionDate` date NOT NULL,
  `SubmissionTime` time NOT NULL,
  `TimeDifference` int DEFAULT NULL,
  PRIMARY KEY (`SubmissionID`),
  KEY `AssignmentID` (`AssignmentID`),
  KEY `ExamID` (`ExamID`),
  KEY `StudentID` (`StudentID`),
  CONSTRAINT `submissions_ibfk_1` FOREIGN KEY (`AssignmentID`) REFERENCES `assignments` (`AssignmentID`) ON DELETE CASCADE,
  CONSTRAINT `submissions_ibfk_2` FOREIGN KEY (`ExamID`) REFERENCES `exams` (`ExamID`) ON DELETE CASCADE,
  CONSTRAINT `submissions_ibfk_3` FOREIGN KEY (`StudentID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `submissions`
--

LOCK TABLES `submissions` WRITE;
/*!40000 ALTER TABLE `submissions` DISABLE KEYS */;
INSERT INTO `submissions` VALUES (3,'Assignment',1,NULL,1,'/files/assignment1.pdf','2024-12-02','14:30:00',NULL),(4,'Assignment',1,NULL,1,'/files/assignment1.pdf','2024-12-02','14:30:00',NULL),(6,'Exam',NULL,1,1,'/files/exam1.pdf','2024-12-15','10:00:00',NULL),(7,'Assignment',1,NULL,1,'/files/assignment3.pdf','2024-12-02','14:30:00',NULL),(8,'Assignment',1,NULL,1,'/files/assignment3.pdf','2024-12-02','14:30:00',NULL),(9,'Assignment',1,NULL,1,'/files/assignment4.pdf','2024-12-02','15:00:00',NULL),(10,'Assignment',1,NULL,1,'/files/assignment_debug.pdf','2024-12-02','15:00:00',NULL),(11,'Assignment',1,NULL,1,'/files/test_assignment.pdf','2024-12-02','15:00:00',NULL);
/*!40000 ALTER TABLE `submissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `UserID` int NOT NULL AUTO_INCREMENT,
  `Role` enum('Student','Professor','Secretary','Admin') NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `PasswordHash` varchar(255) NOT NULL,
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `Email` (`Email`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Student','Alice Smith','student_user@localhost','54e9b1e4263cf0db846a74e9b71f8b36f9976e45fe0910789fa73fe3d6d525f6'),(2,'Professor','Dr. Bob Lee','professor_user@localhost','31e540d3187f889dd94653f8ac110a3998152e5f9d0c322e1062d9a0801332f1'),(3,'Secretary','Carol Hill','secretary_user@localhost','2b7d5f5d3f9d985656a2448cdd12a06af665bfdc4ef1e0ab61244d6fb92926e5'),(4,'Admin','Admin User','admin_user@localhost','29b035ab851555d1cab2085597686f522ea83e13e79ea445e9eda79b4c209fba'),(5,'Student','John Doe','john_doe@localhost','ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `userview`
--

DROP TABLE IF EXISTS `userview`;
/*!50001 DROP VIEW IF EXISTS `userview`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `userview` AS SELECT 
 1 AS `UserID`,
 1 AS `Role`,
 1 AS `Name`,
 1 AS `Email`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `restrictedgrades`
--

/*!50001 DROP VIEW IF EXISTS `restrictedgrades`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY INVOKER */
/*!50001 VIEW `restrictedgrades` AS select `g`.`GradeID` AS `GradeID`,`g`.`StudentID` AS `StudentID`,`g`.`CourseID` AS `CourseID`,`g`.`ProfessorID` AS `ProfessorID`,`g`.`Grade` AS `Grade` from (`grades` `g` join `users` `u` on((`g`.`StudentID` = `u`.`UserID`))) where (`u`.`Email` = current_user()) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `studentexamsview`
--

/*!50001 DROP VIEW IF EXISTS `studentexamsview`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY INVOKER */
/*!50001 VIEW `studentexamsview` AS select `e`.`ExamID` AS `ExamID`,`e`.`CourseID` AS `CourseID`,`c`.`CourseName` AS `CourseName`,`e`.`ScheduledDate` AS `ScheduledDate`,`e`.`ExamTime` AS `ExamTime`,`e`.`FilePath` AS `FilePath` from (((`exams` `e` join `courses` `c` on((`e`.`CourseID` = `c`.`CourseID`))) join `enrollment` `en` on((`c`.`CourseID` = `en`.`CourseID`))) join `users` `u` on((`en`.`StudentID` = `u`.`UserID`))) where ((`u`.`Email` = current_user()) and (concat(`e`.`ScheduledDate`,' ',`e`.`ExamTime`) <= now())) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `userview`
--

/*!50001 DROP VIEW IF EXISTS `userview`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY INVOKER */
/*!50001 VIEW `userview` AS select `users`.`UserID` AS `UserID`,`users`.`Role` AS `Role`,`users`.`Name` AS `Name`,`users`.`Email` AS `Email` from `users` where (`users`.`Email` = current_user()) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-12-06 22:22:49
