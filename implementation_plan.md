# CRM API Integration - Task Checklist

> **Notes:**
> - This checklist tracks the progress of Deep API Integration for the CRM system.
> - ✅ = Completed | 🚧 = In Progress | ⏳ = Pending

## Phase 1: Clients Module - Deep Integration

### 1.1 Comments & Interaction History
- [x] **Logic**: Implement `getComments` in Repository & DataSource (Paginated).
- [x] **Logic**: Create `GetClientCommentsUseCase`.
- [x] **State**: Update `ClientsBloc` to handle `LoadClientComments` & Pagination.
- [x] **UI**: Update `ClientCommentsTab` to display real API data.
- [x] **UI**: Wire "Add Comment" button to `AddComment` UseCase (Input ready, Logic implemented).

### 1.2 Timeline & Activity Log
- [x] **Logic**: Implement `getTimeline` in Repository & Data Source.
- [x] **Logic**: Create `GetClientTimelineUseCase`.
- [x] **State**: Update `ClientsBloc` to handle `LoadClientTimeline`.
- [x] **UI**: Update `ClientTimelineTab` to display real timeline events.

### 1.3 Bulk Actions & Selection
- [x] **UI**: Implement Long-Press on `ClientCard` to trigger selection mode.
- [x] **UI**: Ensure Bulk Actions (Status, Assign, Delete) connect to `ClientsBloc`.
- [x] **Logic**: Implement "Broadcast" feature (currently Mock UI).
- [x] **Logic**: Implement "Export Data" feature (UI + Domain/Data layer).
- [x] **UI**: "Add Client" Screen wiring (Inputs ready, Logic pending).
- [x] **UI**: "Edit Client" Screen wiring (Inputs ready, Logic pending).

## Phase 2: Invoices & Appointments Integration

### 2.1 Invoices Tab
- [x] **Review**: Verify `ClientInvoicesTab` works with `Client` entity data (UI Updated & Integrated).
- [ ] **Logic**: Add specific Invoice actions if needed (Download, etc.).

### 2.2 Appointments Tab
- [x] **Review**: Verify `ClientAppointmentsTab` works with `Client` entity data (UI Updated & Integrated).
- [ ] **Logic**: Add "Schedule Appointment" integration.

## Phase 3: Dashboard & Settings (Next Steps)
- [ ] **Dashboard**: Integrate Dashboard KPIs and Charts.
- [ ] **Settings**: User Profile & System Settings.
