# 🚀 دليل الاستخدام السريع - وحدة الفواتير

## 📱 كيفية استخدام شاشات الفواتير

### 1️⃣ عرض قائمة الفواتير

```dart
// الانتقال إلى شاشة الفواتير
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const InvoicesScreen()),
);
```

**المميزات:**
- ✅ عرض جميع الفواتير
- ✅ بحث بالرقم أو اسم العميل
- ✅ فلترة حسب الحالة
- ✅ تحديث تلقائي (Pull to refresh)
- ✅ تحميل تلقائي للصفحات

---

### 2️⃣ إنشاء فاتورة جديدة

```dart
// من شاشة الفواتير، اضغط على زر +
// أو استخدم:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: invoicesBloc,
      child: const AddEditInvoiceScreen(),
    ),
  ),
);
```

**الحقول المطلوبة:**
- رقم العميل (Client ID)
- وصف البند (Description)
- الكمية (Quantity)
- السعر (Unit Price)

**الحقول الاختيارية:**
- الحالة (Status)
- نسبة الضريبة (Tax Rate)
- الخصم (Discount)
- ملاحظات (Notes)

---

### 3️⃣ عرض تفاصيل الفاتورة

```dart
// اضغط على أي فاتورة من القائمة
// أو استخدم:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: invoicesBloc,
      child: InvoiceDetailsScreen(invoiceId: invoiceId),
    ),
  ),
);
```

**ما يمكنك فعله:**
- ✅ عرض كامل التفاصيل
- ✅ تعديل الفاتورة
- ✅ حذف الفاتورة
- ✅ إرسال الفاتورة (واتساب/SMS)
- ✅ تحميل PDF

---

### 4️⃣ تعديل فاتورة

```dart
// من شاشة التفاصيل، اختر "تعديل" من القائمة
// أو استخدم:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: invoicesBloc,
      child: AddEditInvoiceScreen(invoiceId: invoiceId),
    ),
  ),
);
```

---

## 🎯 أمثلة على الاستخدام

### مثال 1: إنشاء فاتورة بسيطة

```dart
final data = {
  'client_id': 5,
  'status': 'draft',
  'tax_rate': 15,
  'discount': 0,
  'notes': 'شكراً لتعاملكم معنا',
  'items': [
    {
      'description': 'تصميم موقع إلكتروني',
      'quantity': 1,
      'unit_price': 5000,
    },
  ],
};

context.read<InvoicesBloc>().add(CreateInvoiceEvent(data));
```

### مثال 2: البحث عن فاتورة

```dart
// في شاشة الفواتير، اكتب في حقل البحث
// سيتم البحث تلقائياً بعد 500ms

context.read<InvoicesBloc>().add(LoadInvoices(
  search: 'INV-2024',
  isRefresh: true,
));
```

### مثال 3: فلترة حسب الحالة

```dart
// اختر من قائمة الفلتر
context.read<InvoicesBloc>().add(LoadInvoices(
  status: 'paid', // أو 'pending', 'overdue', 'draft'
  isRefresh: true,
));
```

### مثال 4: تغيير حالة الفاتورة

```dart
context.read<InvoicesBloc>().add(
  ChangeInvoiceStatusEvent(invoiceId, 'paid'),
);
```

### مثال 5: إرسال فاتورة

```dart
context.read<InvoicesBloc>().add(
  SendInvoiceEvent(invoiceId, ['whatsapp', 'sms']),
);
```

### مثال 6: حذف فاتورة

```dart
context.read<InvoicesBloc>().add(DeleteInvoiceEvent(invoiceId));
```

---

## 🔄 حالات الـ Bloc

### Loading State
```dart
if (state.status == InvoicesStatus.loading) {
  return CircularProgressIndicator();
}
```

### Success State
```dart
if (state.status == InvoicesStatus.success) {
  final invoices = state.invoices;
  // عرض القائمة
}
```

### Error State
```dart
if (state.status == InvoicesStatus.failure) {
  final errorMessage = state.errorMessage;
  // عرض رسالة الخطأ
}
```

### Operation Status
```dart
// للعمليات (إنشاء، تعديل، حذف)
if (state.operationStatus == InvoiceOperationStatus.success) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.operationMessage)),
  );
}
```

---

## 🎨 تخصيص الواجهة

### تغيير الألوان
الألوان معرفة في `AppColorScheme`:
- `primary` - اللون الأساسي
- `success` - للفواتير المدفوعة
- `warning` - للفواتير المعلقة
- `error` - للفواتير المتأخرة

### تغيير النصوص
النصوص معرفة في `AppStrings` (يمكن إضافتها)

---

## ⚠️ ملاحظات مهمة

### 1. Bloc Provider
تأكد دائماً من توفير الـ Bloc عند الانتقال:
```dart
BlocProvider.value(
  value: invoicesBloc,
  child: YourScreen(),
)
```

### 2. Dependency Injection
الـ Bloc مسجل في `di_container.dart`:
```dart
final invoicesBloc = getIt<InvoicesBloc>();
```

### 3. Error Handling
جميع الأخطاء يتم التعامل معها تلقائياً وعرضها للمستخدم

### 4. Pagination
التحميل التلقائي يعمل عند الوصول لـ 90% من القائمة

---

## 🐛 حل المشاكل الشائعة

### المشكلة: الفواتير لا تظهر
**الحل:**
1. تحقق من اتصال الإنترنت
2. تحقق من الـ API endpoint في `end_points.dart`
3. تحقق من الـ token في `TokenStorage`

### المشكلة: لا يمكن إنشاء فاتورة
**الحل:**
1. تأكد من ملء جميع الحقول المطلوبة
2. تأكد من صحة رقم العميل
3. تحقق من الـ validation errors

### المشكلة: البحث لا يعمل
**الحل:**
1. انتظر 500ms بعد الكتابة
2. تحقق من الـ debounce في الكود

---

## 📞 للمساعدة

راجع:
- `INVOICES_COMPLETION_SUMMARY.md` - ملخص كامل
- `MASTER_IMPLEMENTATION_PLAN.md` - الخطة التفصيلية
- `api-doc/DOCS_INVOICES_APPOINTMENTS.md` - توثيق API

---

## ✅ Checklist للاختبار

- [ ] عرض قائمة الفواتير
- [ ] البحث عن فاتورة
- [ ] فلترة حسب الحالة
- [ ] إنشاء فاتورة جديدة
- [ ] عرض تفاصيل فاتورة
- [ ] تعديل فاتورة
- [ ] حذف فاتورة
- [ ] تغيير حالة فاتورة
- [ ] إرسال فاتورة
- [ ] Pull to refresh
- [ ] Pagination

**جميع المميزات جاهزة للاستخدام! 🎉**
