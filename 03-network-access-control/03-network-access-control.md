---

theme: sred-theme
title: "Network Access Control"
info: |
  Network Security Using Dedicated Devices
  Open-source teaching deck
transition: slide-left
mdc: true
---

# Network Access Control

## Deciding who gets onto the network

__Open-source lab stack:__ PacketFence, FreeRADIUS, Linux/Open vSwitch

NAC moves the question from **which port is active?** to **which user/device should receive which access?**

---

# Learning objectives

You should be able to:

- explain the 802.1X roles;
- distinguish authentication from authorization;
- explain RADIUS at a high level;
- compare 802.1X and MAC Authentication Bypass;
- design guest and quarantine flows;
- understand PacketFence as an open-source NAC platform.

---

# The basic problem

```mermaid
flowchart LR
  U["Unknown laptop"] --> P["Wall port"]
  P --> S["Switch"]
  S --> LAN["Corporate LAN"]
```

Should plugging in a cable immediately grant normal internal access?

A secure enterprise usually wants an **admission decision** first.

---

# NAC as a decision point

```mermaid
flowchart LR
  D["Device connects"] --> I["Identify / authenticate"]
  I --> P["Evaluate policy"]
  P --> A["Assign access"]
  A --> M["Monitor / re-evaluate"]
```

NAC combines identity, network control, and policy.

---

# Three 802.1X roles

```mermaid
flowchart LR
  SUP["Supplicant / endpoint"] --> AUTH["Authenticator / switch/AP"]
  AUTH --> AAA["Authentication server / RADIUS"]
```

Remember the roles, not vendor names.

---

# Supplicant

The supplicant is the endpoint component that participates in authentication.

Examples:

- operating-system 802.1X client;
- managed laptop agent;
- Wi-Fi supplicant.

It presents credentials or participates in a certificate-based exchange.

---

# Authenticator

The switch or AP controls the edge port.

Before successful authentication, it can permit only traffic needed for the authentication process.

```mermaid
flowchart LR
  PC["Endpoint"] --> S["Controlled port"]
  S -->|"before auth"| X["Limited access"]
  S -->|"after auth"| LAN["Authorized network"]
```

---

# Authentication server

The authentication server evaluates the supplied identity and returns a result.

Often:

- RADIUS server;
- backed by local users, LDAP, certificates, or identity infrastructure.

The network device does not need to store every enterprise credential.

---

# 802.1X message path

```mermaid
sequenceDiagram
  participant E as Endpoint
  participant S as Switch/AP
  participant R as RADIUS server
  E->>S: EAPOL authentication
  S->>R: RADIUS Access-Request
  R-->>S: Access-Accept / Reject
  S-->>E: Port authorized or denied
```

The authenticator relays the decision into network access.

---

# Authentication vs authorization

Authentication asks:

> Who or what are you?

Authorization asks:

> What should you be allowed to access?

NAC is valuable because it can connect the two.

---

# Dynamic authorization

A successful user does not need the same policy as every other user.

Possible outcomes:

```text
employee laptop  -> VLAN 10
contractor       -> VLAN 20
guest            -> VLAN 50
printer           -> VLAN 60
noncompliant PC   -> quarantine
```

---

# Dynamic VLAN assignment

```mermaid
flowchart TB
  R["RADIUS decision"] --> E{"Identity / role"}
  E -->|Employee| V10["VLAN 10"]
  E -->|Guest| V50["VLAN 50"]
  E -->|IoT| V60["VLAN 60"]
  E -->|Risk| Q["Quarantine"]
```

The physical socket no longer defines the full trust level.

---

# RADIUS: what students need

RADIUS provides AAA-related messages between the network access device and the authentication server.

At this level, understand:

- request;
- accept/reject/challenge;
- attributes;
- accounting.

Do not turn the lecture into RADIUS packet trivia.

---

# RADIUS attributes

Attributes can carry policy information such as:

- VLAN assignment;
- user role;
- session timeout;
- access restrictions;
- accounting identifiers.

This is how an identity decision becomes a network configuration decision.

---

# EAP: keep the abstraction

802.1X transports EAP methods.

Different EAP methods authenticate in different ways.

For this lecture, the important security questions are:

- password or certificate?
- server authenticated?
- endpoint authenticated?
- are credentials exposed to an untrusted intermediary?

---

# Certificate-based access

```mermaid
flowchart LR
  DEV["Managed device / certificate"] --> NAC["802.1X / NAC"]
  NAC --> CA["Trusted certificate chain"]
  NAC --> POL["Managed-device policy"]
```

Certificates can provide stronger machine identity than MAC addresses.

---

# User vs machine identity

A laptop may have:

- device identity;
- logged-in user identity.

Security policy may care about both.

Example:

> Corporate laptop + employee user = normal access.

> Corporate laptop before login = limited infrastructure access.

---

# The IoT problem

Many devices cannot run a normal 802.1X supplicant:

- printers;
- cameras;
- badge readers;
- building systems;
- embedded appliances.

NAC still needs a way to classify them.

---

# MAC Authentication Bypass

```mermaid
flowchart LR
  IOT["Printer / MAC X"] --> SW["Switch"]
  SW --> RAD["RADIUS lookup / MAC X"]
  RAD --> POL["Printer VLAN / policy"]
```

MAB improves manageability, but the MAC address remains spoofable.

---

# MAB is not strong authentication

Treat it as:

- inventory-based admission;
- compatibility mechanism;
- policy hook for devices without 802.1X.

Do not present it as cryptographic proof of device identity.

---

# Guest access

```mermaid
flowchart LR
  G["Guest device"] --> NAC["NAC"]
  NAC --> PORTAL["Registration / captive portal"]
  PORTAL --> GV["Guest VLAN"]
  GV --> NET["Internet only"]
```

Guest access should not imply internal trust.

---

# Captive portal limitations

A captive portal is useful for:

- registration;
- terms of use;
- simple guest onboarding.

It is not strong endpoint security by itself.

Modern HTTPS behavior can also make interception-based portal workflows awkward.

---

# Quarantine network

```mermaid
flowchart LR
  D["Risky endpoint"] --> Q["Quarantine VLAN"]
  Q --> FIX["Update / remediation services"]
  Q -.-> X["No normal internal access"]
```

Quarantine is valuable only if there is a realistic recovery path.

---

# Posture assessment

A NAC solution may consider signals such as:

- OS version;
- device enrollment;
- endpoint agent state;
- certificate status;
- vulnerability or compliance signals.

Be cautious: posture checks add complexity and can become brittle.

---

# Policy should match risk

Do not make every condition binary.

Possible policy outcomes:

```text
trusted        -> normal
partially known -> restricted
unknown        -> guest
high risk       -> quarantine
denied          -> no access
```

Graduated access can improve usability and resilience.

---

# Wired NAC

```mermaid
flowchart LR
  PC["Laptop"] --> SW["Access switch"]
  SW --> R["RADIUS / PacketFence"]
  SW --> LAN["Assigned VLAN / ACL"]
```

The switch is the enforcement point.

---

# Wireless NAC

```mermaid
flowchart LR
  PC["Laptop"] --> AP["Access point"]
  AP --> R["RADIUS / PacketFence"]
  AP --> WLAN["Role / VLAN / policy"]
```

The same AAA concepts can apply even though the access medium changes.

---

# NAC and segmentation

NAC does not replace segmentation.

It helps decide **which segment or role** an endpoint should receive.

```mermaid
flowchart LR
  ID["Identity decision"] --> SEG["Segment / role"]
  SEG --> FW["Firewall policy"]
  FW --> APP["Applications"]
```

---

# NAC and least privilege

Instead of:

```text
Authenticated = entire internal network
```

prefer:

```text
Authenticated + role + device state
  -> only required access
```

NAC can provide context, but downstream firewalls still enforce application flows.

---

# Open-source platform: PacketFence

PacketFence provides open-source NAC capabilities including:

- 802.1X integration;
- RADIUS;
- registration;
- captive portal workflows;
- device profiling;
- VLAN/role assignment;
- isolation/quarantine patterns.

---

# PacketFence architecture

```mermaid
flowchart TB
  END["Endpoints"] --> NET["Switches / APs"]
  NET --> PF["PacketFence"]
  PF --> RAD["RADIUS services"]
  PF --> ID["Identity source"]
  PF --> DB["Device / policy data"]
  PF --> NET
```

It is useful for teaching because the control relationships are visible.

---

# FreeRADIUS

FreeRADIUS can also be used independently for a smaller teaching lab.

```mermaid
flowchart LR
  SW["Authenticator"] --> FR["FreeRADIUS"]
  FR --> USERS["Local users / LDAP / cert policy"]
```

Start small before introducing a full NAC platform.

---

# Lab topology

```mermaid
flowchart LR
  E1["Student endpoint"] --> OVS["Open vSwitch"]
  E2["Printer endpoint"] --> OVS
  OVS --> PF["PacketFence / FreeRADIUS"]
  OVS --> R["Router / firewall"]
```

The goal is to observe different access decisions for different endpoint identities.

---

# Demo sequence

1. Endpoint connects with no authentication.
2. Show restricted state.
3. Authenticate a known user/device.
4. Show role/VLAN assignment.
5. Attempt with unknown identity.
6. Show guest or quarantine result.

Make the **state transition** visible.

---

# NAC state machine

```mermaid
stateDiagram-v2
  [*] --> Unknown
  Unknown --> Authenticating
  Authenticating --> Authorized: valid identity
  Authenticating --> Guest: guest workflow
  Authenticating --> Quarantine: policy risk
  Authenticating --> Denied: reject
  Quarantine --> Authorized: remediated
```

---

# Failure: RADIUS unavailable

What happens if the authentication service fails?

Choices may include:

- fail closed;
- fail open;
- critical VLAN;
- cached authorization.

This is an availability design decision, not merely a configuration checkbox.

---

# Failure: certificate expired

```mermaid
flowchart LR
  DEV["Managed device"] --> CERT{"Certificate valid?"}
  CERT -->|Yes| ACCESS["Normal access"]
  CERT -->|No| REC["Restricted remediation"]
```

A strong identity system still needs lifecycle management.

---

# Failure: switch cannot enforce role

NAC policy may be correct while the access device is misconfigured.

Always separate:

- policy decision point;
- policy enforcement point.

```mermaid
flowchart LR
  PDP["Policy decision"] --> PEP["Switch/AP enforcement"]
```

---

# Profiling

NAC platforms may infer device type from behavior or metadata.

Examples:

- DHCP fingerprints;
- observed services;
- vendor OUI;
- traffic patterns.

Profiling is **probabilistic context**, not proof of identity.

---

# Privacy considerations

NAC can collect substantial endpoint and user context.

Ask:

- what data is necessary?
- how long is it retained?
- who can query it?
- is profiling transparent and justified?

Security visibility should still be governed.

---

# Logging and investigations

Useful NAC events:

- successful/failed authentication;
- assigned role/VLAN;
- device first seen;
- endpoint moved ports;
- quarantine events;
- policy changes;
- RADIUS failures.

These events help connect **identity to network activity**.

---

# Common bypass attempts

Attackers may try:

- MAC spoofing against MAB;
- using an already authorized port/device;
- rogue mini-switch behind an endpoint;
- credential theft;
- exploiting fail-open behavior.

NAC reduces risk; it does not make edge access infallible.

---

# Design scenario

A university network has:

- staff laptops;
- student laptops;
- printers;
- lab equipment;
- visitors.

Design an admission policy with no more than five roles.

Keep the policy understandable enough to operate.

---

# Possible role model

```mermaid
flowchart TB
  AUTH["NAC decision"] --> STAFF["Staff"]
  AUTH --> STUD["Students"]
  AUTH --> IOT["IoT / printers"]
  AUTH --> GUEST["Guests"]
  AUTH --> QUAR["Quarantine"]
```

Each role should map to downstream firewall policy.

---

# Common mistakes

- Treating MAB as strong identity
- Granting broad access after authentication
- Building too many roles to operate
- No remediation path for quarantine
- Ignoring RADIUS/NAC outages
- Expired certificate surprises
- Profiling treated as certainty
- No integration with downstream segmentation

---

# What NAC cannot solve

NAC does not know whether:

- an authenticated user is abusing an application;
- a permitted HTTPS request is SQL injection;
- malware runs after successful admission;
- data is being exfiltrated through an allowed service.

Admission is one control in a larger system.

---

# Mental model

```mermaid
flowchart LR
  CONNECT["Connect"] --> AUTH["Authenticate / identify"]
  AUTH --> CONTEXT["Add context"]
  CONTEXT --> ROLE["Assign role"]
  ROLE --> ENFORCE["Switch/AP enforces"]
  ENFORCE --> DOWN["Firewall / app policy"]
```

---

# Expert augmentation: NAC to Zero Trust

Traditional NAC often grants network reachability after admission.

Zero Trust changes the unit of decision:

```mermaid
flowchart LR
  U[User + device] --> PDP[Policy decision point]
  PDP --> PEP[Policy enforcement point]
  PEP --> APP[Single application]
```

Decision inputs can include:

- identity;
- device posture;
- requested application;
- location and risk;
- session context.

---

# ZTNA model: no broad network trust

Instead of exposing a whole subnet:

```mermaid
flowchart LR
  USER[User] --> ZTNA[ZTNA enforcement]
  ZTNA --> APP1[Allowed app]
  ZTNA -. blocked .-> DB[Database subnet]
  ZTNA -. hidden .-> SCAN[Network scanning]
```

NAC remains useful at the access edge.

ZTNA adds:

- application-specific authorization;
- continuous policy checks;
- better control for remote and cloud resources;
- smaller lateral-movement blast radius.

---

# Review questions

1. What are the three 802.1X roles?
2. What is the difference between authentication and authorization?
3. Why is MAB weaker than certificate-based access?
4. What is a quarantine VLAN for?
5. What happens when RADIUS is unavailable?
6. Why does NAC not replace firewalls?

---

# Final checklist

For a NAC design, ask:

- Which endpoint types exist?
- Which can support 802.1X?
- What identity sources are trusted?
- What roles are actually necessary?
- What happens to guests and unknown devices?
- What is the quarantine/remediation path?
- What happens during infrastructure failure?
- How is the assigned role enforced downstream?
