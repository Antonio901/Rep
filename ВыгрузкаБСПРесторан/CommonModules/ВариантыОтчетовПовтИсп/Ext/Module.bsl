﻿#Область СлужебныйПрограммныйИнтерфейс

// Формирует список отчетов конфигурации, доступных текущему пользователю.
// Его следует использовать во всех запросах к таблице
// справочника "ВариантыОтчетов" как отбор по реквизиту "Отчет".
//
// Возвращаемое значение:
//   Массив - ссылки отчетов, доступных текущему пользователю.
//            Тип элементов см. в реквизите Справочники.ВариантыОтчетов.Реквизиты.Отчет.
//
Функция ДоступныеОтчеты(ПроверятьФункциональныеОпции = Истина) Экспорт
	Результат = Новый Массив;
	ПолныеИменаОтчетов = Новый Массив;
	
	УстановленныеРасширенияДоступны = Неопределено;
	ПоУмолчаниюВсеПодключены = Неопределено;
	Для Каждого ОтчетМетаданные Из Метаданные.Отчеты Цикл
		Если Не ПравоДоступа("Просмотр", ОтчетМетаданные)
			Или Не ВариантыОтчетов.ОтчетПодключенКХранилищу(ОтчетМетаданные, ПоУмолчаниюВсеПодключены)
			Или СтандартныеПодсистемыСервер.ЭтоОбъектРасширенияНеразделенногоПользователя(ОтчетМетаданные, УстановленныеРасширенияДоступны) Тогда
			Продолжить;
		КонецЕсли;
		Если ПроверятьФункциональныеОпции
			И Не ОбщегоНазначения.ОбъектМетаданныхДоступенПоФункциональнымОпциям(ОтчетМетаданные) Тогда
			Продолжить;
		КонецЕсли;
		ПолныеИменаОтчетов.Добавить(ОтчетМетаданные.ПолноеИмя());
	КонецЦикла;
	
	ИдентификаторыОтчетов = ОбщегоНазначения.ИдентификаторыОбъектовМетаданных(ПолныеИменаОтчетов);
	Для Каждого ИдентификаторОтчета Из ИдентификаторыОтчетов Цикл
		Результат.Добавить(ИдентификаторОтчета.Значение);
	КонецЦикла;
	
	Возврат Новый ФиксированныйМассив(Результат);
КонецФункции

// Формирует список вариантов отчетов конфигурации, недоступных текущему пользователю по функциональным опциям.
// Следует использовать во всех запросах к таблице
// справочника "ВариантыОтчетов" как исключающий отбор по реквизиту "ПредопределенныйВариант".
//
// Возвращаемое значение:
//   Массив - варианты отчетов, которые отключены по функциональным опциям.
//            Тип элементов - СправочникСсылка.ПредопределенныеВариантыОтчетов,
//            СправочникСсылка.ПредопределенныеВариантыОтчетовРасширений.
//
Функция ОтключенныеВариантыПрограммы() Экспорт
	// Получить варианты, недоступные по функциональным опциям.
	
	ТаблицаОпций = ВариантыОтчетовПовтИсп.Параметры().ТаблицаФункциональныхОпций;
	
	ТаблицаВариантов = ТаблицаОпций.СкопироватьКолонки("ПредопределенныйВариант, ИмяФункциональнойОпции");
	ТаблицаВариантов.Колонки.Добавить("ЗначениеОпции", Новый ОписаниеТипов("Число"));
	
	ОтчетыПользователя = ВариантыОтчетовПовтИсп.ДоступныеОтчеты();
	Для Каждого ОтчетСсылка Из ОтчетыПользователя Цикл
		Найденные = ТаблицаОпций.НайтиСтроки(Новый Структура("Отчет", ОтчетСсылка));
		Для Каждого СтрокаТаблицы Из Найденные Цикл
			СтрокаВариант = ТаблицаВариантов.Добавить();
			ЗаполнитьЗначенияСвойств(СтрокаВариант, СтрокаТаблицы);
			Значение = ПолучитьФункциональнуюОпцию(СтрокаТаблицы.ИмяФункциональнойОпции);
			Если Значение = Истина Тогда
				СтрокаВариант.ЗначениеОпции = 1;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	ТаблицаВариантов.Свернуть("ПредопределенныйВариант", "ЗначениеОпции");
	ТаблицаОтключенных = ТаблицаВариантов.Скопировать(Новый Структура("ЗначениеОпции", 0));
	ТаблицаОтключенных.Свернуть("ПредопределенныйВариант");
	ОтключенныеВарианты = ТаблицаОтключенных.ВыгрузитьКолонку("ПредопределенныйВариант");
	
	// Добавить варианты, отключенные разработчиком.
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ОтчетыПользователя", ОтчетыПользователя);
	Запрос.УстановитьПараметр("ВерсияРасширений", ПараметрыСеанса.ВерсияРасширений);
	Запрос.УстановитьПараметр("МассивОтключенных", ОтключенныеВарианты);
	Запрос.Текст =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВариантыКонфигурации.Ссылка
	|ИЗ
	|	Справочник.ПредопределенныеВариантыОтчетов КАК ВариантыКонфигурации
	|ГДЕ
	|	(ВариантыКонфигурации.Включен = ЛОЖЬ
	|		ИЛИ ВариантыКонфигурации.ПометкаУдаления = ИСТИНА)
	|	И ВариантыКонфигурации.Отчет В(&ОтчетыПользователя)
	|	И НЕ ВариантыКонфигурации.Ссылка В (&МассивОтключенных)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВариантыРасширений.Ссылка
	|ИЗ
	|	Справочник.ПредопределенныеВариантыОтчетовРасширений КАК ВариантыРасширений
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПредопределенныеВариантыОтчетовВерсийРасширений КАК Версии
	|		ПО ВариантыРасширений.Ссылка = Версии.Вариант
	|			И ВариантыРасширений.Отчет = Версии.Отчет
	|			И (Версии.ВерсияРасширений = &ВерсияРасширений)
	|ГДЕ
	|	(ВариантыРасширений.Включен = ЛОЖЬ
	|		ИЛИ Версии.Вариант ЕСТЬ NULL)
	|	И ВариантыРасширений.Отчет В(&ОтчетыПользователя)
	|	И НЕ ВариантыРасширений.Ссылка В (&МассивОтключенных)";
	
	ОтключенныеРазработчиком = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку(0);
	ОбщегоНазначенияКлиентСервер.ДополнитьМассив(ОтключенныеВарианты, ОтключенныеРазработчиком);
	Возврат Новый ФиксированныйМассив(ОтключенныеВарианты);
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Формирует дерево подсистем, доступных текущему пользователю.
//
// Возвращаемое значение: 
//   Результат - ДеревоЗначений -
//       * РазделСсылка - СправочникСсылка.ИдентификаторыОбъектовМетаданных - Ссылка раздела.
//       * Ссылка       - СправочникСсылка.ИдентификаторыОбъектовМетаданных - Ссылка подсистемы.
//       * Имя           - Строка - Имя подсистемы.
//       * ПолноеИмя     - Строка - Полное имя подсистемы.
//       * Представление - Строка - Представление подсистемы.
//       * Приоритет     - Строка - Приоритет подсистемы.
//
Функция ПодсистемыТекущегоПользователя() Экспорт
	
	ОписаниеТиповИдентификатора = Новый ОписаниеТипов;
	ОписаниеТиповИдентификатора.Типы().Добавить("СправочникСсылка.ИдентификаторыОбъектовМетаданных");
	ОписаниеТиповИдентификатора.Типы().Добавить("СправочникСсылка.ИдентификаторыОбъектовРасширений");
	
	Результат = Новый ДеревоЗначений;
	Результат.Колонки.Добавить("Ссылка",              ОписаниеТиповИдентификатора);
	Результат.Колонки.Добавить("Имя",                 ВариантыОтчетов.ОписаниеТиповСтрока(150));
	Результат.Колонки.Добавить("ПолноеИмя",           ВариантыОтчетов.ОписаниеТиповСтрока(510));
	Результат.Колонки.Добавить("Представление",       ВариантыОтчетов.ОписаниеТиповСтрока(150));
	Результат.Колонки.Добавить("РазделСсылка",        ОписаниеТиповИдентификатора);
	Результат.Колонки.Добавить("РазделПолноеИмя",     ВариантыОтчетов.ОписаниеТиповСтрока(510));
	Результат.Колонки.Добавить("Приоритет",           ВариантыОтчетов.ОписаниеТиповСтрока(100));
	Результат.Колонки.Добавить("ПолноеПредставление", ВариантыОтчетов.ОписаниеТиповСтрока(300));
	
	КорневаяСтрока = Результат.Строки.Добавить();
	КорневаяСтрока.Ссылка = Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка();
	КорневаяСтрока.Представление = НСтр("ru = 'Все разделы'");
	
	МассивПолныхИмен = Новый Массив;
	ПолныеИменаСтрокДерева = Новый Соответствие;
	
	УстановленныеРасширенияДоступны = Неопределено;
	ИдентификаторНачальнойСтраницы = ВариантыОтчетовКлиентСервер.ИдентификаторНачальнойСтраницы();
	СписокРазделов = ВариантыОтчетов.СписокРазделов();
	
	Приоритет = 0;
	Для Каждого ЭлементСписка Из СписокРазделов Цикл
		
		РазделМетаданные = ЭлементСписка.Значение;
		Если НЕ (ТипЗнч(РазделМетаданные) = Тип("ОбъектМетаданных") И СтрНачинаетсяС(РазделМетаданные.ПолноеИмя(), "Подсистема"))
			И НЕ (ТипЗнч(РазделМетаданные) = Тип("Строка") И РазделМетаданные = ИдентификаторНачальнойСтраницы) Тогда
			
			ВызватьИсключение НСтр("ru='Некорректно определены значения разделов в процедуре ВариантыОтчетовПереопределяемый.ОпределитьРазделыСВариантамиОтчетов'");
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ЭлементСписка.Представление) Тогда
			ШаблонЗаголовка = ЭлементСписка.Представление;
		Иначе
			ШаблонЗаголовка = НСтр("ru = 'Отчеты раздела ""%1""'");
		КонецЕсли;
		ЭтоНачальнаяСтраница = (РазделМетаданные = ИдентификаторНачальнойСтраницы);
		
		Если Не ЭтоНачальнаяСтраница
			И (Не ПравоДоступа("Просмотр", РазделМетаданные)
				Или Не ОбщегоНазначения.ОбъектМетаданныхДоступенПоФункциональнымОпциям(РазделМетаданные)
				Или СтандартныеПодсистемыСервер.ЭтоОбъектРасширенияНеразделенногоПользователя(РазделМетаданные, УстановленныеРасширенияДоступны)) Тогда
			Продолжить; // Подсистема не доступна по ФО или по правам.
		КонецЕсли;
		
		СтрокаДерева = КорневаяСтрока.Строки.Добавить();
		Если ЭтоНачальнаяСтраница Тогда
			СтрокаДерева.Имя           = ИдентификаторНачальнойСтраницы;
			СтрокаДерева.ПолноеИмя     = ИдентификаторНачальнойСтраницы;
			СтрокаДерева.Представление = НСтр("ru = 'Начальная страница'");
		Иначе
			СтрокаДерева.Имя           = РазделМетаданные.Имя;
			СтрокаДерева.ПолноеИмя     = РазделМетаданные.ПолноеИмя();
			СтрокаДерева.Представление = РазделМетаданные.Представление();
		КонецЕсли;
		МассивПолныхИмен.Добавить(СтрокаДерева.ПолноеИмя);
		Если ПолныеИменаСтрокДерева[СтрокаДерева.ПолноеИмя] = Неопределено Тогда
			ПолныеИменаСтрокДерева.Вставить(СтрокаДерева.ПолноеИмя, СтрокаДерева);
		Иначе
			ПолныеИменаСтрокДерева.Вставить(СтрокаДерева.ПолноеИмя, Истина); // Требуется поиск по дереву.
		КонецЕсли;
		СтрокаДерева.РазделПолноеИмя = СтрокаДерева.ПолноеИмя;
		СтрокаДерева.ПолноеПредставление = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			ШаблонЗаголовка,
			СтрокаДерева.Представление);
		
		Приоритет = Приоритет + 1;
		СтрокаДерева.Приоритет = Формат(Приоритет, "ЧЦ=4; ЧДЦ=0; ЧВН=; ЧГ=0");
		Если Не ЭтоНачальнаяСтраница Тогда
			ДобавитьПодсистемыТекущегоПользователя(СтрокаДерева, РазделМетаданные, МассивПолныхИмен, ПолныеИменаСтрокДерева, УстановленныеРасширенияДоступны);
		КонецЕсли;
	КонецЦикла;
	
	СсылкиПодсистем = ОбщегоНазначения.ИдентификаторыОбъектовМетаданных(МассивПолныхИмен);
	Для Каждого КлючИЗначение Из СсылкиПодсистем Цикл
		СтрокаДерева = ПолныеИменаСтрокДерева[КлючИЗначение.Ключ];
		Если СтрокаДерева = Истина Тогда // Требуется поиск по дереву.
			Найденные = Результат.Строки.НайтиСтроки(Новый Структура("ПолноеИмя", КлючИЗначение.Ключ), Истина);
			Для Каждого СтрокаДерева Из Найденные Цикл
				СтрокаДерева.Ссылка = КлючИЗначение.Значение;
				СтрокаДерева.РазделСсылка = СсылкиПодсистем[СтрокаДерева.РазделПолноеИмя];
			КонецЦикла;
		Иначе
			СтрокаДерева.Ссылка = КлючИЗначение.Значение;
			СтрокаДерева.РазделСсылка = СсылкиПодсистем[СтрокаДерева.РазделПолноеИмя];
		КонецЕсли;
	КонецЦикла;
	ПолныеИменаСтрокДерева.Очистить();
	
	Возврат Результат;
КонецФункции

// Добавляет подсистемы родителя с фильтром по правам доступа и функциональным опциям.
Процедура ДобавитьПодсистемыТекущегоПользователя(СтрокаРодителя, МетаданныеРодителя, МассивПолныхИмен, ПолныеИменаСтрокДерева, УстановленныеРасширенияДоступны)
	ПриоритетРодителя = СтрокаРодителя.Приоритет;
	
	Приоритет = 0;
	Для Каждого ПодсистемаМетаданные Из МетаданныеРодителя.Подсистемы Цикл
		Приоритет = Приоритет + 1;
		
		Если Не ПодсистемаМетаданные.ВключатьВКомандныйИнтерфейс
			Или Не ПравоДоступа("Просмотр", ПодсистемаМетаданные)
			Или Не ОбщегоНазначения.ОбъектМетаданныхДоступенПоФункциональнымОпциям(ПодсистемаМетаданные)
			Или СтандартныеПодсистемыСервер.ЭтоОбъектРасширенияНеразделенногоПользователя(ПодсистемаМетаданные, УстановленныеРасширенияДоступны) Тогда
			Продолжить; // Подсистема не доступна по ФО или по правам.
		КонецЕсли;
		
		СтрокаДерева = СтрокаРодителя.Строки.Добавить();
		СтрокаДерева.Имя           = ПодсистемаМетаданные.Имя;
		СтрокаДерева.ПолноеИмя     = ПодсистемаМетаданные.ПолноеИмя();
		СтрокаДерева.Представление = ПодсистемаМетаданные.Представление();
		МассивПолныхИмен.Добавить(СтрокаДерева.ПолноеИмя);
		Если ПолныеИменаСтрокДерева[СтрокаДерева.ПолноеИмя] = Неопределено Тогда
			ПолныеИменаСтрокДерева.Вставить(СтрокаДерева.ПолноеИмя, СтрокаДерева);
		Иначе
			ПолныеИменаСтрокДерева.Вставить(СтрокаДерева.ПолноеИмя, Истина); // Требуется поиск по дереву.
		КонецЕсли;
		СтрокаДерева.РазделПолноеИмя = СтрокаРодителя.РазделПолноеИмя;
		
		Если СтрДлина(ПриоритетРодителя) > 12 Тогда
			СтрокаДерева.ПолноеПредставление = СтрокаРодителя.Представление + ": " + СтрокаДерева.Представление;
		Иначе
			СтрокаДерева.ПолноеПредставление = СтрокаДерева.Представление;
		КонецЕсли;
		СтрокаДерева.Приоритет = ПриоритетРодителя + Формат(Приоритет, "ЧЦ=4; ЧДЦ=0; ЧВН=; ЧГ=0");
		
		ДобавитьПодсистемыТекущегоПользователя(СтрокаДерева, ПодсистемаМетаданные, МассивПолныхИмен, ПолныеИменаСтрокДерева, УстановленныеРасширенияДоступны);
	КонецЦикла;
КонецПроцедуры

// Возвращает Истина если у пользователя есть право чтения вариантов отчетов.
Функция ПравоЧтения() Экспорт
	Возврат ПравоДоступа("Чтение", Метаданные.Справочники.ВариантыОтчетов);
КонецФункции

// Возвращает Истина если у пользователя есть право на сохранение вариантов отчетов.
Функция ПравоДобавления() Экспорт
	Возврат ПравоДоступа("СохранениеДанныхПользователя", Метаданные) И ПравоДоступа("Добавление", Метаданные.Справочники.ВариантыОтчетов);
КонецФункции

// Параметры подсистемы, закэшированные при обновлении.
Функция Параметры() Экспорт
	ПолноеИмяПодсистемы = ВариантыОтчетовКлиентСервер.ПолноеИмяПодсистемы();
	
	Параметры = СтандартныеПодсистемыСервер.ПараметрРаботыПрограммы(ПолноеИмяПодсистемы);
	Если Параметры = Неопределено Тогда
		ВариантыОтчетов.ОперативноеОбновлениеОбщихДанныхКонфигурации(Новый Структура("РазделенныеОбработчики"));
		Параметры = СтандартныеПодсистемыСервер.ПараметрРаботыПрограммы(ПолноеИмяПодсистемы);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПараметрыСеанса.ВерсияРасширений) Тогда
		ПараметрыРасширений = СтандартныеПодсистемыСервер.ПараметрРаботыРасширения(ПолноеИмяПодсистемы);
		Если ПараметрыРасширений = Неопределено Тогда
			Если Не Пользователи.ЭтоПолноправныйПользователь() Тогда
				УстановитьПривилегированныйРежим(Истина);
				Если Не ПривилегированныйРежим() Тогда
					ВызватьИсключение НСтр("ru = 'Не удалось обновить вспомогательные данные расширений. Обратитесь к администратору.'");
				КонецЕсли;
			КонецЕсли;
			Настройки = Новый Структура;
			Настройки.Вставить("Конфигурация",      Ложь);
			Настройки.Вставить("Расширения",        Истина);
			Настройки.Вставить("ОбщиеДанные",       Истина);
			Настройки.Вставить("РазделенныеДанные", Истина);
			Настройки.Вставить("Оперативное",       Истина);
			Настройки.Вставить("Отложенное",        Истина);
			Настройки.Вставить("Полное",            Истина);
			ВариантыОтчетов.Обновить(Настройки);
			ПараметрыРасширений = СтандартныеПодсистемыСервер.ПараметрРаботыРасширения(ПолноеИмяПодсистемы);
		КонецЕсли;
		Если ПараметрыРасширений <> Неопределено Тогда
			ОбщегоНазначенияКлиентСервер.ДополнитьМассив(Параметры.ОтчетыСНастройками, ПараметрыРасширений.ОтчетыСНастройками);
			ОбщегоНазначенияКлиентСервер.ДополнитьТаблицу(Параметры.ТаблицаФункциональныхОпций, ПараметрыРасширений.ТаблицаФункциональныхОпций);
		КонецЕсли;
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки") Тогда
		МодульДополнительныеОтчетыИОбработки = ОбщегоНазначения.ОбщийМодуль("ДополнительныеОтчетыИОбработки");
		МодульДополнительныеОтчетыИОбработки.ПриОпределенииОтчетовСНастройками(Параметры.ОтчетыСНастройками);
	КонецЕсли;
	
	Возврат Параметры;
КонецФункции

#КонецОбласти
