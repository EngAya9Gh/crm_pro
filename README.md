# 🏢 CRM Wakeel - نظام إدارة علاقات العملاء

<div dir="rtl">

## 📱 نظرة عامة

نظام CRM متكامل لإدارة العملاء والفواتير والمواعيد مبني بتقنية Flutter مع بنية معمارية نظيفة (Clean Architecture).

</div>

---

## ✨ المميزات الحالية

### ✅ إدارة العملاء (Clients Management)
- عرض وإدارة قائمة العملاء
- ملف تعريف كامل للعميل مع تابات متعددة
- التعليقات والتايم لاين
- تحديد متعدد وعمليات جماعية
- تصدير CSV

### ✅ إدارة الفواتير (Invoices Management) - **جديد!**
- إنشاء وتعديل الفواتير
- عرض تفاصيل كاملة للفاتورة
- بحث وفلترة متقدمة
- تغيير حالة الفاتورة
- إرسال الفواتير (واتساب/SMS)
- تحميل PDF
- Pagination تلقائي

### 🚧 قيد التطوير
- إدارة المواعيد (Appointments)
- لوحة التحكم (Dashboard)

---

## 🏗️ البنية المعمارية

### Clean Architecture
```
lib/
├── core/              # الأساسيات المشتركة
│   ├── common/        # Models & Widgets مشتركة
│   ├── config/        # الإعدادات والثيمات
│   ├── error/         # معالجة الأخطاء
│   ├── services/      # الخدمات (DI, Network)
│   └── utils/         # الأدوات المساعدة
│
└── features/          # المميزات
    ├── clients/       # وحدة العملاء
    ├── invoices/      # وحدة الفواتير ✅
    ├── appointments/  # وحدة المواعيد 🚧
    └── dashboard/     # لوحة التحكم
```

### كل Feature يتبع:
```
feature/
├── data/
│   ├── datasources/   # مصادر البيانات
│   ├── models/        # نماذج البيانات
│   └── repositories/  # تطبيق المستودعات
├── domain/
│   ├── entities/      # الكيانات
│   ├── repositories/  # واجهات المستودعات
│   └── usecases/      # حالات الاستخدام
└── presentation/
    ├── bloc/          # إدارة الحالة
    ├── views/         # الشاشات
    └── widgets/       # الـ Widgets الخاصة
```

---

## 🛠️ التقنيات المستخدمة

### Core
- **Flutter SDK:** ^3.10.1
- **Dart:** ^3.10.1

### State Management
- **flutter_bloc:** ^8.1.6
- **equatable:** ^2.0.5

### Dependency Injection
- **get_it:** ^7.7.0

### Networking
- **dio:** ^5.5.0+1

### Functional Programming
- **dartz:** ^0.10.1

### Storage
- **flutter_secure_storage:** ^10.0.0
- **shared_preferences:** ^2.5.4

### UI/UX
- **google_fonts:** ^6.2.1
- **fl_chart:** ^0.68.0
- **shimmer:** ^3.0.0

---

## 🚀 البدء السريع

### المتطلبات
- Flutter SDK 3.10.1 أو أحدث
- Dart 3.10.1 أو أحدث

### التثبيت

```bash
# 1. استنساخ المشروع
git clone [repository-url]
cd crm_wakeel

# 2. تثبيت الحزم
flutter pub get

# 3. تشغيل المشروع
flutter run
```

### الإعداد

1. تحديث API Base URL في `lib/core/utils/end_points.dart`
2. التأكد من توفر Backend API
3. تشغيل التطبيق

---

## 📚 التوثيق

### ⭐ ابدأ من هنا
- **[INDEX.md](INDEX.md)** - فهرس شامل لجميع الملفات
- **[FINAL_SUMMARY.md](FINAL_SUMMARY.md)** - الملخص النهائي
- **[PROJECT_STATUS.md](PROJECT_STATUS.md)** - حالة المشروع

### الأدلة
- **[INVOICES_USAGE_GUIDE.md](INVOICES_USAGE_GUIDE.md)** - دليل استخدام الفواتير
- **[rules.md](rules.md)** - قواعد بنية المشروع

### الخطط
- **[MASTER_IMPLEMENTATION_PLAN.md](MASTER_IMPLEMENTATION_PLAN.md)** - الخطة الكاملة
- **[TASK_CHECKLIST.md](TASK_CHECKLIST.md)** - قائمة المهام

### API
- **[api-doc/DOCS_INVOICES_APPOINTMENTS.md](api-doc/DOCS_INVOICES_APPOINTMENTS.md)**
- **[api-doc/DOCS_CLIENTS_AUTH.md](api-doc/DOCS_CLIENTS_AUTH.md)**

---

## 📊 حالة المشروع

| المرحلة | الحالة | النسبة |
|---------|--------|--------|
| Client Management | ✅ مكتمل | 100% |
| Invoices CRUD | ✅ مكتمل | 100% |
| Appointments CRUD | 🚧 جاري | 15% |
| Dashboard | ⏳ قادم | 0% |

**الإنجاز الكلي: 54%** 📈

---

## 🎨 لقطات الشاشة

### شاشة الفواتير
- قائمة الفواتير مع بحث وفلترة
- تفاصيل الفاتورة الكاملة
- إضافة/تعديل فاتورة

*(يمكن إضافة الصور هنا)*

---

## 🧪 الاختبار

### تشغيل التحليل
```bash
flutter analyze
```

### تشغيل الاختبارات
```bash
flutter test
```

---

## 📝 القواعد والمعايير

### البنية المعمارية
- ✅ Clean Architecture
- ✅ SOLID Principles
- ✅ Separation of Concerns

### الكود
- ✅ Consistent Naming (snake_case للملفات، PascalCase للكلاسات)
- ✅ Code Documentation
- ✅ Error Handling شامل

### UI/UX
- ✅ استخدام Widgets موحدة من `core/common/widgets`
- ✅ الألوان من `AppColorScheme`
- ✅ النصوص من `AppTypography`

راجع **[rules.md](rules.md)** للتفاصيل الكاملة.

---

## 🤝 المساهمة

### قبل المساهمة
1. اقرأ [rules.md](rules.md)
2. راجع [MASTER_IMPLEMENTATION_PLAN.md](MASTER_IMPLEMENTATION_PLAN.md)
3. اتبع البنية الموجودة في `lib/features/invoices`

### خطوات المساهمة
1. Fork المشروع
2. أنشئ branch جديد (`git checkout -b feature/AmazingFeature`)
3. Commit التغييرات (`git commit -m 'Add some AmazingFeature'`)
4. Push للـ branch (`git push origin feature/AmazingFeature`)
5. افتح Pull Request

---

## 📄 الترخيص

هذا المشروع خاص بـ CRM Wakeel.

---

## 👥 الفريق

- **التطوير:** تم باستخدام Clean Architecture
- **التاريخ:** يناير 2026
- **الحالة:** قيد التطوير النشط

---

## 📞 الدعم

للأسئلة والمشاكل:
- راجع [INDEX.md](INDEX.md) للتنقل السريع
- راجع [INVOICES_USAGE_GUIDE.md](INVOICES_USAGE_GUIDE.md) للاستخدام
- راجع التوثيق في `api-doc/`

---

## 🎯 الخطوات التالية

### قريباً
- [ ] إكمال وحدة المواعيد (Appointments)
- [ ] تحديث لوحة التحكم (Dashboard)
- [ ] إضافة الإشعارات
- [ ] دعم متعدد اللغات

### مستقبلاً
- [ ] تقارير متقدمة
- [ ] تكامل مع أنظمة خارجية
- [ ] تطبيق موبايل native

---

## ⭐ الإنجازات الأخيرة

### ✅ تم مؤخراً (24 يناير 2026)
- إنشاء تكامل كامل لوحدة الفواتير
- 3 شاشات UI احترافية
- 8 Use Cases كاملة
- State Management متقدم
- توثيق شامل

راجع [FINAL_SUMMARY.md](FINAL_SUMMARY.md) للتفاصيل الكاملة.

---

<div align="center">

**مبني بـ ❤️ باستخدام Flutter**

**CRM Wakeel © 2026**

</div>
