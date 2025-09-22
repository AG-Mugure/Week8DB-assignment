# Clinic Booking System – README

##  Overview
This project implements a **Clinic Booking System** using **MySQL**. The database schema is designed to manage patients, doctors, appointments, 
medical records, prescriptions, payments
and insurance. It demonstrates relational modeling with **constraints, relationships, stored procedures, and views**.

##  Objectives
- Manage **patients, staff, and doctors**.
- Handle **appointments** with conflict checks for doctor and room availability.
- Record **medical records, prescriptions, and medications**.
- Track **payments and insurance coverage**.
- Support **many-to-many relationships** (appointments ↔ services, patients ↔ allergies, prescriptions ↔ medications).
- Provide **views and procedures** for common operations.

##  Features
- **Users Table** → Stores staff information with roles (doctor, nurse, receptionist, etc.).
- **Patients Table** → Stores patient demographic details.
- **Doctors Table** → Links users to doctor profiles with specialization.
- **Appointments Table** → Manages scheduling, status, and conflicts.
- **Services & Appointment Services** → Billable services tied to appointments.
- **Medical Records** → Diagnoses and notes per appointment.
- **Medications & Prescriptions** → Tracks prescribed medications and dosage.
- **Payments** → Handles different payment methods and statuses.
- **Insurance** → Patients linked to insurance providers.
- **Allergies** → Many-to-many relationship with patients.

##  Constraints & Relationships
- **Primary Keys**: Ensure uniqueness of each record.
- **Foreign Keys**: Enforce relationships between entities.
- **Unique Constraints**: Prevent duplicate usernames, emails, IDs and overlapping appointments.
- **Enums**: Enforce controlled values (e.g., appointment status, roles, gender, payment method).

## ⚡ Advanced Features
- **Stored Procedure (`book_appointment`)** → Checks availability before inserting an appointment.
- **View (`v_upcoming_appointments`)** → Lists all future appointments with patient and doctor names.
- **Indexes** → Improve query performance on frequently searched fields.

## ▶️ How to Run
1. Open **MySQL Workbench** or any MySQL client.
2. Copy and execute the `clinic_booking_system.sql` file.
3. The database `clinic_db` will be created with all tables, relationships and sample stored procedures/views.

```sql
SOURCE clinic_booking_system.sql;
```

4. Verify by running:
```sql
SHOW TABLES;
```

## 📂 File Structure
- `clinic_booking_system.sql` → Contains all `CREATE DATABASE`, `CREATE TABLE`, constraints, stored procedure, and view definitions.
- `README.md` → Project description and usage instructions.

## ✅ Deliverables
- Complete relational schema with constraints.
- Normalized tables with **1NF, 2NF, 3NF** compliance.
- Example procedure and view.

---
This database can be extended further with **audit logs, role-based access control, reporting dashboards, and integration with a frontend system**.
