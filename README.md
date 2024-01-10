# Microservices for Radiology Workflow Optimization

This repository contains the source code for several microservices designed to optimize radiology workflow processes. They contribute to efficiency improvements, reduce the likelihood of errors, and save time in daily operations. The microservices are developed to automate tasks related to email notifications, content delivery, and data management across multiple sources.

## Microservices Overview

As described in the corresponding paper:

1.  **E-Mail Notifications**: Automates the task of sending an email to the relevant staff members (RAD_mr_fellows, RAD_dodmail, RAD_FOREIGN).
    
2.  **RIS-PACS-Dictation Software content delivery**: Automatically extracts relevant information from the RIS and PACS systems and populates it into report templates in the dictation software (RAD_oralcontrast, RAD_pretty_history).
    
3.  **Displaying Information from Multiple Sources**: Queries information from different systems and merges them to display in a single coherent audit trail or a webpage (RAD_whoison, RAD_audit_trail).
    

## How to Use

The code in this repository serves as a template to be modified according to your department's needs. Certain aspects, such as internal packages, need to be changed before using them in a production environment.

## Getting Started

1.  Clone the repository

```bash
git clone https://github.com/ASBecker/Microservices-for-Radiology-Workflow-Optimization.git
```

2.  Navigate to the cloned repository

```bash
cd Microservices-for-Radiology-Workflow-Optimization
```

3.  Modify the code to suit your department's specific operations

## License

This project is licensed under the MIT License. See `LICENSE.md` for more information.

## Contact

If you have any questions, issues, or concerns, please file an issue in this repository's Issue Tracker.
