﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

// Возвращает реквизиты объекта, которые разрешается редактировать
// с помощью обработки группового изменения реквизитов.
//
// Возвращаемое значение:
//  Массив - список имен реквизитов объекта.
Функция РеквизитыРедактируемыеВГрупповойОбработке() Экспорт
	
	РедактируемыеРеквизиты = Новый Массив;
	
	Возврат РедактируемыеРеквизиты;
	
КонецФункции

// Конец СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

#КонецОбласти

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Обновляет состав наименований предопределенных наборов в
// параметрах дополнительных реквизитов и сведений.
// 
// Параметры:
//  ЕстьИзменения - Булево (возвращаемое значение) - если производилась запись,
//                  устанавливается Истина, иначе не изменяется.
//
Процедура ОбновитьСоставНаименованийПредопределенныхНаборов(ЕстьИзменения = Неопределено) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ПредопределенныеНаборы = ПредопределенныеНаборы();
	
	НачатьТранзакцию();
	Попытка
		ЕстьТекущиеИзменения = Ложь;
		СтароеЗначение = Неопределено;
		
		СтандартныеПодсистемыСервер.ОбновитьПараметрРаботыПрограммы(
			"СтандартныеПодсистемы.Свойства.ПредопределенныеНаборыДополнительныхРеквизитовИСведений",
			ПредопределенныеНаборы, ЕстьТекущиеИзменения, СтароеЗначение);
		
		СтандартныеПодсистемыСервер.ДобавитьИзмененияПараметраРаботыПрограммы(
			"СтандартныеПодсистемы.Свойства.ПредопределенныеНаборыДополнительныхРеквизитовИСведений",
			?(ЕстьТекущиеИзменения,
			  Новый ФиксированнаяСтруктура("ЕстьИзменения", Истина),
			  Новый ФиксированнаяСтруктура()) );
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	Если ЕстьТекущиеИзменения Тогда
		ЕстьИзменения = Истина;
	КонецЕсли;
	
КонецПроцедуры



Процедура ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	ОбновляемыеОбъекты = Новый Массив;
	ОбновляемыеОбъекты.Добавить(Справочники.НаборыДополнительныхРеквизитовИСведений.Справочник_Контрагенты);
	ОбновляемыеОбъекты.Добавить(Справочники.НаборыДополнительныхРеквизитовИСведений.УдалитьСправочник_Контрагенты);
	ОбновляемыеОбъекты.Добавить(Справочники.НаборыДополнительныхРеквизитовИСведений.СправочникКонтрагенты_Основное);
	ОбновляемыеОбъекты.Добавить(Справочники.НаборыДополнительныхРеквизитовИСведений.Документ_СчетНаОплатуПокупателю);
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ДополнительныеРеквизиты.Свойство КАК Свойство
		|ИЗ
		|	Справочник.НаборыДополнительныхРеквизитовИСведений.ДополнительныеРеквизиты КАК ДополнительныеРеквизиты
		|ГДЕ
		|	ДополнительныеРеквизиты.Ссылка = &Ссылка
		|
		|УПОРЯДОЧИТЬ ПО
		|	Свойство
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ДополнительныеСведения.Свойство КАК Свойство
		|ИЗ
		|	Справочник.НаборыДополнительныхРеквизитовИСведений.ДополнительныеСведения КАК ДополнительныеСведения
		|ГДЕ
		|	ДополнительныеСведения.Ссылка = &Ссылка
		|
		|УПОРЯДОЧИТЬ ПО
		|	Свойство";
	
	Запрос.УстановитьПараметр("Ссылка", Справочники.НаборыДополнительныхРеквизитовИСведений.УдалитьСправочник_Контрагенты);
	
	РезультатЗапроса = Запрос.ВыполнитьПакет();
	ДополнительныеРеквизитыГруппы = РезультатЗапроса[0].Выгрузить().ВыгрузитьКолонку("Свойство");
	ДополнительныеСведенияГруппы  = РезультатЗапроса[1].Выгрузить().ВыгрузитьКолонку("Свойство");
	
	ОбщегоНазначенияКлиентСервер.ДополнитьМассив(ОбновляемыеОбъекты, ДополнительныеРеквизитыГруппы);
	ОбщегоНазначенияКлиентСервер.ДополнитьМассив(ОбновляемыеОбъекты, ДополнительныеСведенияГруппы);
	
	ОбновлениеИнформационнойБазы.ОтметитьКОбработке(Параметры, ОбновляемыеОбъекты);
	
КонецПроцедуры

Процедура ОбработатьДанныеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	ПараметрыНаборов = УправлениеСвойствами.СтруктураПараметровНабораСвойств();
	МассивНаборов = Новый Массив;
	МассивНаборов.Добавить("Справочник_Контрагенты");
	МассивНаборов.Добавить("СправочникКонтрагенты_Основное");
	МассивНаборов.Добавить("СправочникКонтрагенты_Прочее");
	МассивНаборов.Добавить("Документ_СчетНаОплатуПокупателю");
	Для Каждого Набор Из МассивНаборов Цикл
		УправлениеСвойствами.УстановитьПараметрыНабораСвойств(Набор, ПараметрыНаборов);
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ДополнительныеРеквизиты.Свойство КАК Свойство
		|ИЗ
		|	Справочник.НаборыДополнительныхРеквизитовИСведений.ДополнительныеРеквизиты КАК ДополнительныеРеквизиты
		|ГДЕ
		|	ДополнительныеРеквизиты.Ссылка = &Ссылка
		|
		|УПОРЯДОЧИТЬ ПО
		|	Свойство
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ДополнительныеСведения.Свойство КАК Свойство
		|ИЗ
		|	Справочник.НаборыДополнительныхРеквизитовИСведений.ДополнительныеСведения КАК ДополнительныеСведения
		|ГДЕ
		|	ДополнительныеСведения.Ссылка = &Ссылка
		|
		|УПОРЯДОЧИТЬ ПО
		|	Свойство";
	
	Запрос.УстановитьПараметр("Ссылка", Справочники.НаборыДополнительныхРеквизитовИСведений.УдалитьСправочник_Контрагенты);
	
	РезультатЗапроса = Запрос.ВыполнитьПакет();
	ДополнительныеРеквизитыГруппы = РезультатЗапроса[0].Выгрузить();
	ДополнительныеСведенияГруппы  = РезультатЗапроса[1].Выгрузить();
	
	Если ДополнительныеРеквизитыГруппы.Количество() = 0
		И ДополнительныеСведенияГруппы.Количество() = 0 Тогда
		Параметры.ОбработкаЗавершена = Истина;
		Возврат;
	КонецЕсли;
	
	НаборСсылка = Справочники.НаборыДополнительныхРеквизитовИСведений.СправочникКонтрагенты_Основное;
	НаборОбъект = НаборСсылка.ПолучитьОбъект();
	
	// Перенос дополнительных реквизитов из удаленного набора в новый.
	НаборОбъект.ДополнительныеРеквизиты.Загрузить(ДополнительныеРеквизитыГруппы);
	НаборОбъект.ДополнительныеСведения.Загрузить(ДополнительныеСведенияГруппы);
	
	// Вычисление количества свойств не помеченных на удаление.
	КоличествоРеквизитов = Формат(НаборОбъект.ДополнительныеРеквизиты.НайтиСтроки(
		Новый Структура("ПометкаУдаления", Ложь)).Количество(), "ЧГ=");
	
	КоличествоСведений   = Формат(НаборОбъект.ДополнительныеСведения.НайтиСтроки(
		Новый Структура("ПометкаУдаления", Ложь)).Количество(), "ЧГ=");
	
	НаборОбъект.КоличествоРеквизитов = КоличествоРеквизитов;
	НаборОбъект.КоличествоСведений   = КоличествоСведений;
	
	ОбновлениеИнформационнойБазы.ЗаписатьОбъект(НаборОбъект);
	
	// Обновление дополнительных реквизитов.
	Для Каждого Строка Из ДополнительныеРеквизитыГруппы Цикл
		РеквизитОбъект = Строка.Свойство.ПолучитьОбъект();
		РеквизитОбъект.НаборСвойств = НаборСсылка;
		ОбновлениеИнформационнойБазы.ЗаписатьОбъект(РеквизитОбъект);
	КонецЦикла;
	
	// Обновление дополнительных сведений.
	Для Каждого Строка Из ДополнительныеСведенияГруппы Цикл
		РеквизитОбъект = Строка.Свойство.ПолучитьОбъект();
		РеквизитОбъект.НаборСвойств = НаборСсылка;
		ОбновлениеИнформационнойБазы.ЗаписатьОбъект(РеквизитОбъект);
	КонецЦикла;
	
	// Заполнение родительского набора.
	НаборСсылка = Справочники.НаборыДополнительныхРеквизитовИСведений.Справочник_Контрагенты;
	НаборОбъект = НаборСсылка.ПолучитьОбъект();
	
	НаборОбъект.ДополнительныеРеквизиты.Загрузить(ДополнительныеРеквизитыГруппы);
	НаборОбъект.ДополнительныеСведения.Загрузить(ДополнительныеСведенияГруппы);
	
	ОбновлениеИнформационнойБазы.ЗаписатьОбъект(НаборОбъект);
	
	// Очистка устаревшего набора.
	УстаревшийНабор = Справочники.НаборыДополнительныхРеквизитовИСведений.УдалитьСправочник_Контрагенты;
	УстаревшийНаборОбъект = УстаревшийНабор.ПолучитьОбъект();
	УстаревшийНаборОбъект.ДополнительныеРеквизиты.Очистить();
	УстаревшийНаборОбъект.ДополнительныеСведения.Очистить();
	
	ОбновлениеИнформационнойБазы.ЗаписатьОбъект(УстаревшийНаборОбъект);
	
	УправлениеСвойствами.ОбновитьНаименованияНаборовИСвойств();
	
	Параметры.ОбработкаЗавершена = Истина;
	
КонецПроцедуры


#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПредопределенныеНаборы()
	
	ПредопределенныеНаборы = Новый Соответствие;
	
	ИменаПредопределенных = Метаданные.Справочники.НаборыДополнительныхРеквизитовИСведений.ПолучитьИменаПредопределенных();
	
	Для каждого Имя Из ИменаПредопределенных Цикл
		ПредопределенныеНаборы.Вставить(
			Имя, УправлениеСвойствамиСлужебный.НаименованиеПредопределенногоНабора(Имя));
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(ПредопределенныеНаборы);
	
КонецФункции

#КонецОбласти

#КонецЕсли
