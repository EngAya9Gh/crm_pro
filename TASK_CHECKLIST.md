# CRM API Integration - Task Checklist (محدّث)

> آخر تحديث: 24 يناير 2026

---

## المرحلة 1: تابات ملف العميل (Client Profile Tabs) ✅ مكتملة

### 1.1 تاب التعليقات (Comments Tab) ✅
- [x] إنشاء `GetClientCommentsUseCase`
- [x] إضافة `getComments` method للـ DataSource
- [x] إضافة `getComments` method للـ Repository
- [x] إضافة `LoadClientComments` Event للـ Bloc
- [x] تحديث `ClientCommentsTab` لجلب البيانات من API
- [x] إضافة تعليق جديد (`AddClientCommentEvent`)

### 1.2 تاب الـ Timeline ✅
- [x] إنشاء `GetClientTimelineUseCase`
- [x] إضافة `LoadClientTimeline` Event للـ Bloc
- [x] تحديث `ClientTimelineTab` لجلب البيانات من API

### 1.3 تفعيل وضع التحديد (Bulk Selection) ✅
- [x] إضافة `onLongPress` callback لـ `ClientCard`
- [x] ربط Long Press بتفعيل `_isSelectionMode` في `ClientsScreen`
- [x] تصدير CSV (`ExportClientsEvent`)
- [x] بث رسالة جماعية (Mock UI)

---

## المرحلة 2: الفواتير (Invoices CRUD) 🚧

### Data Layer
- [x] تحديث `Invoice` Entity لتطابق API Response
- [ ] إنشاء `InvoiceItem` Entity
- [x] إنشاء `InvoiceModel` مع `fromJson`/`toJson`
- [ ] إنشاء `InvoiceItemModel`
- [ ] إنشاء `InvoicesRemoteDataSource` (Abstract)
- [ ] إنشاء `InvoicesRemoteDataSourceImpl`
- [ ] إنشاء `InvoicesRepository` (Abstract)
- [ ] إنشاء `InvoicesRepositoryImpl`

### Domain Layer
- [ ] `GetInvoicesUseCase`
- [ ] `GetInvoiceDetailsUseCase`
- [ ] `CreateInvoiceUseCase`
- [ ] `UpdateInvoiceUseCase`
- [ ] `DeleteInvoiceUseCase`
- [ ] `ChangeInvoiceStatusUseCase`
- [ ] `SendInvoiceUseCase`
- [ ] `DownloadInvoicePdfUseCase`

### Presentation Layer
- [ ] إنشاء `InvoicesBloc` + Events + States
- [ ] تحديث `InvoicesScreen` بربط Bloc
- [ ] إنشاء `AddEditInvoiceScreen`
- [ ] إنشاء `InvoiceDetailsScreen`

---

## المرحلة 3: المواعيد (Appointments CRUD) 🚧

### Data Layer
- [x] تحديث `Appointment` Entity
- [x] إنشاء `AppointmentModel`
- [ ] إنشاء `AppointmentsRemoteDataSource` (Abstract)
- [ ] إنشاء `AppointmentsRemoteDataSourceImpl`
- [ ] إنشاء `AppointmentsRepository` (Abstract)
- [ ] إنشاء `AppointmentsRepositoryImpl`

### Domain Layer
- [ ] `GetAppointmentsUseCase`
- [ ] `GetAppointmentDetailsUseCase`
- [ ] `CreateAppointmentUseCase`
- [ ] `UpdateAppointmentUseCase`
- [ ] `DeleteAppointmentUseCase`
- [ ] `ChangeAppointmentStatusUseCase`

### Presentation Layer
- [ ] إنشاء `AppointmentsBloc` + Events + States
- [ ] تحديث `AppointmentsScreen` بربط Bloc
- [ ] إنشاء `AddEditAppointmentScreen`
- [ ] إنشاء `AppointmentDetailsScreen`

---

## المرحلة 4: لوحة التحكم (Dashboard) ⏳

### Data Layer
- [ ] إنشاء `DashboardSummary` Entity
- [ ] إنشاء `DashboardCharts` Entity
- [ ] إنشاء `RecentActivity` Entity
- [ ] إنشاء Dashboard Models
- [ ] إنشاء `DashboardRemoteDataSource`
- [ ] إنشاء `DashboardRepository`

### Domain Layer
- [ ] `GetDashboardSummaryUseCase`
- [ ] `GetDashboardChartsUseCase`
- [ ] `GetRecentActivitiesUseCase`

### Presentation Layer
- [ ] إنشاء `DashboardBloc`
- [ ] تحديث `DashboardScreen` بربط Bloc

---

## المرحلة 5: التسجيل في DI Container ⏳

- [ ] تسجيل Invoices Feature (DataSource, Repository, UseCases, Bloc)
- [ ] تسجيل Appointments Feature
- [ ] تسجيل Dashboard Feature
- [ ] إضافة Endpoints الناقصة

---

## المرحلة 6: التحقق والاختبار 🚧

### Client Profile ✅
- [x] التعليقات تأتي من API
- [x] Timeline يأتي من API
- [x] إضافة تعليق جديد يعمل
- [x] الضغط المطول يفعل وضع التحديد

### Invoices ⏳
- [ ] القائمة من API
- [ ] إنشاء فاتورة
- [ ] تعديل فاتورة
- [ ] تغيير حالة
- [ ] حذف فاتورة
- [ ] تحميل PDF

### Appointments ⏳
- [ ] القائمة من API
- [ ] إنشاء موعد
- [ ] تعديل موعد
- [ ] حذف موعد

### Dashboard ⏳
- [ ] Summary من API
- [ ] Charts من API
- [ ] Recent Activities من API

---

## ملخص التقدم

| المرحلة | التقدم |
|---------|--------|
| 1. Client Profile Tabs | ✅ 100% |
| 2. Invoices CRUD | 🚧 15% (Entity/Model فقط) |
| 3. Appointments CRUD | 🚧 15% (Entity/Model فقط) |
| 4. Dashboard | ⏳ 0% |
| 5. DI Registration | ⏳ 0% |
| 6. Testing | 🚧 25% |

---

## الخطوة التالية

**نبدأ بـ:** المرحلة 2 - إنشاء Invoices Data Layer كاملاً (DataSource + Repository) ثم الـ Use Cases والـ Bloc.
