-- Clinic Booking System
-- SQL schema for MySQL (InnoDB)

CREATE DATABASE clinic_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE clinic_db;

-- Users: staff and system users
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(150) UNIQUE,
  phone VARCHAR(25),
  role ENUM('receptionist','nurse','doctor','admin','pharmacist','accountant') NOT NULL DEFAULT 'receptionist',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Patients
CREATE TABLE patients (
  patient_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  date_of_birth DATE,
  gender ENUM('male','female','other'),
  phone VARCHAR(25),
  email VARCHAR(150),
  address VARCHAR(255),
  national_id VARCHAR(50) UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Doctors
CREATE TABLE doctors (
  doctor_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  license_number VARCHAR(100) UNIQUE,
  specialization VARCHAR(150),
  bio TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_doctor_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Rooms (for in-person consultations or procedures)
CREATE TABLE rooms (
  room_id INT AUTO_INCREMENT PRIMARY KEY,
  room_name VARCHAR(50) NOT NULL UNIQUE,
  description VARCHAR(255),
  capacity INT DEFAULT 1
) ENGINE=InnoDB;

-- Services offered (consultation, lab test, vaccination, etc.)
CREATE TABLE services (
  service_id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  description VARCHAR(255),
  price DECIMAL(10,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB;

-- Appointments
CREATE TABLE appointments (
  appointment_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  doctor_id INT,
  scheduled_start DATETIME NOT NULL,
  scheduled_end DATETIME NOT NULL,
  room_id INT,
  status ENUM('scheduled','checked_in','in_consultation','completed','cancelled','no_show') NOT NULL DEFAULT 'scheduled',
  reason VARCHAR(255),
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
  CONSTRAINT fk_appointment_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE SET NULL,
  CONSTRAINT fk_appointment_room FOREIGN KEY (room_id) REFERENCES rooms(room_id) ON DELETE SET NULL,
  CONSTRAINT fk_appointment_creator FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
  CONSTRAINT uq_appointment_unique_time_patient UNIQUE (patient_id, scheduled_start)
) ENGINE=InnoDB;

-- Many-to-many: appointment <-> service (an appointment can include multiple billable services)
CREATE TABLE appointment_services (
  appointment_id INT NOT NULL,
  service_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (appointment_id, service_id),
  CONSTRAINT fk_as_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE CASCADE,
  CONSTRAINT fk_as_service FOREIGN KEY (service_id) REFERENCES services(service_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Medical records / diagnoses per appointment
CREATE TABLE medical_records (
  record_id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT NOT NULL UNIQUE,
  summary TEXT,
  diagnosis VARCHAR(255),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_medrec_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Medications (catalog)
CREATE TABLE medications (
  medication_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  brand VARCHAR(150),
  form ENUM('tablet','capsule','syrup','injection','ointment','other') DEFAULT 'tablet',
  strength VARCHAR(50),
  sku VARCHAR(100) UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Prescriptions
CREATE TABLE prescriptions (
  prescription_id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT NOT NULL,
  prescribed_by INT NULL,
  notes TEXT,
  issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_presc_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE CASCADE,
  CONSTRAINT fk_presc_doctor_user FOREIGN KEY (prescribed_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- prescription -> medication (many-to-many, with dosage instructions)
CREATE TABLE prescription_medications (
  prescription_id INT NOT NULL,
  medication_id INT NOT NULL,
  dosage VARCHAR(100) NOT NULL,
  frequency VARCHAR(100),
  duration VARCHAR(100),
  notes VARCHAR(255),
  PRIMARY KEY (prescription_id, medication_id),
  CONSTRAINT fk_pm_prescription FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id) ON DELETE CASCADE,
  CONSTRAINT fk_pm_medication FOREIGN KEY (medication_id) REFERENCES medications(medication_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Payments
CREATE TABLE payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT,
  patient_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  method ENUM('cash','card','mobile_money','insurance','other') NOT NULL,
  status ENUM('pending','completed','failed','refunded') NOT NULL DEFAULT 'pending',
  paid_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payment_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE SET NULL,
  CONSTRAINT fk_payment_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Insurance providers
CREATE TABLE insurance_providers (
  provider_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  phone VARCHAR(50),
  email VARCHAR(150)
) ENGINE=InnoDB;

-- patient insurance (one patient can have multiple policies)
CREATE TABLE patient_insurance (
  patient_insurance_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  provider_id INT NOT NULL,
  policy_number VARCHAR(150) NOT NULL,
  active BOOLEAN DEFAULT TRUE,
  CONSTRAINT fk_pi_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
  CONSTRAINT fk_pi_provider FOREIGN KEY (provider_id) REFERENCES insurance_providers(provider_id) ON DELETE RESTRICT,
  CONSTRAINT uq_patient_policy UNIQUE (patient_id, policy_number)
) ENGINE=InnoDB;

-- Allergies (catalog)
CREATE TABLE allergies (
  allergy_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  description VARCHAR(255)
) ENGINE=InnoDB;

-- patient <-> allergy (many-to-many)
CREATE TABLE patient_allergies (
  patient_id INT NOT NULL,
  allergy_id INT NOT NULL,
  reaction VARCHAR(255),
  recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (patient_id, allergy_id),
  CONSTRAINT fk_pa_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
  CONSTRAINT fk_pa_allergy FOREIGN KEY (allergy_id) REFERENCES allergies(allergy_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Indexes to speed up common queries
CREATE INDEX idx_appointments_doctor ON appointments(doctor_id);
CREATE INDEX idx_appointments_patient ON appointments(patient_id);
CREATE INDEX idx_appointments_status ON appointments(status);

-- stored procedure for booking an appointment (basic checks)
DELIMITER $$
CREATE PROCEDURE book_appointment(
  IN p_patient_id INT,
  IN p_doctor_id INT,
  IN p_start DATETIME,
  IN p_end DATETIME,
  IN p_room_id INT,
  IN p_created_by INT
)
BEGIN
  -- Basic conflict check: doctor availability
  IF EXISTS(
    SELECT 1 FROM appointments a
    WHERE a.doctor_id = p_doctor_id
      AND a.status IN ('scheduled','checked_in','in_consultation')
      AND (p_start < a.scheduled_end AND p_end > a.scheduled_start)
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor not available in requested time slot';
  END IF;

  -- Basic conflict check: room availability (if provided)
  IF p_room_id IS NOT NULL AND EXISTS(
    SELECT 1 FROM appointments a
    WHERE a.room_id = p_room_id
      AND a.status IN ('scheduled','checked_in','in_consultation')
      AND (p_start < a.scheduled_end AND p_end > a.scheduled_start)
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room not available in requested time slot';
  END IF;

  INSERT INTO appointments (patient_id, doctor_id, scheduled_start, scheduled_end, room_id, created_by)
  VALUES (p_patient_id, p_doctor_id, p_start, p_end, p_room_id, p_created_by);
END$$
DELIMITER ;

-- upcoming appointments
CREATE OR REPLACE VIEW v_upcoming_appointments AS
SELECT a.appointment_id, a.patient_id, CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
       a.doctor_id, u.full_name AS doctor_name, a.scheduled_start, a.scheduled_end, a.status
FROM appointments a
LEFT JOIN patients p ON a.patient_id = p.patient_id
LEFT JOIN doctors d ON a.doctor_id = d.doctor_id
LEFT JOIN users u ON d.user_id = u.user_id
WHERE a.scheduled_start >= NOW();


