graph TD
    subgraph "Users"
        A[Internal Users(Help Desk Staff)] -->|1. Authenticate| B(Microsoft Entra ID(For Employee Mgmt)[Core Identity])
        C[External Users(Private Customers)] -->|2. Authenticate| D(Microsoft Entra External ID (B2C)(For Customer Mgmt))
    end

    subgraph "Identity & Access Management (IAM) - Microsoft Entra Services"
        B -->|3. Access Policy Eval| E(Microsoft Entra Conditional Access(Zero Trust Enforcement))
        D -->|3. Access Policy Eval| E
        E -->|Conditional Access Decision| F(Microsoft Entra MFA(Multi-Factor Authentication - If Required))
        F -->|Authenticated & Authorized Access| G[The New Application(Internal & External Usage)]
    end

    subgraph "Security & Governance"
        H[Microsoft Entra Identity Protection(Real-time Identity Risk Detection)] -->|5. Continuous Risk Monitoring| E
        I[Microsoft Entra Access Reviews(Periodic Permission Audits)]
    end

    G -->|Access/Usage| H
