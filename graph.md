graph TD
    subgraph "Users"
        A[Internal Users<br>(Help Desk Staff)] -->|1. Authenticate| B(Microsoft Entra ID<br>(For Employee Mgmt)<br>[Core Identity])
        C[External Users<br>(Private Customers)] -->|2. Authenticate| D(Microsoft Entra External ID (B2C)<br>(For Customer Mgmt))
    end

    subgraph "Identity & Access Management (IAM) - Microsoft Entra Services"
        B -->|3. Access Policy Eval| E(Microsoft Entra Conditional Access<br>(Zero Trust Enforcement))
        D -->|3. Access Policy Eval| E
        E -->|Conditional Access Decision| F(Microsoft Entra MFA<br>(Multi-Factor Authentication - If Required))
        F -->|Authenticated & Authorized Access| G[The New Application<br>(Internal & External Usage)]
    end

    subgraph "Security & Governance"
        H[Microsoft Entra Identity Protection<br>(Real-time Identity Risk Detection)] -->|5. Continuous Risk Monitoring| E
        I[Microsoft Entra Access Reviews<br>(Periodic Permission Audits)]
    end

    G -->|Access/Usage| H
