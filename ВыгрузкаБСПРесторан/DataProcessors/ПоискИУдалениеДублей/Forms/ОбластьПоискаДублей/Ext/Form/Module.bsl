﻿// Ожидаются параметры:
//
//     ОбластьПоискаДублей - Строка - Полное имя метаданных таблицы ранее выбранной области поиска.
//
// Возвращается результатом выбора:
//
//     Неопределено - Отказ от редактирования.
//     Строка       - Адрес временного хранилища новых настроек компоновщика.
//

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	Параметры.Свойство("ОбластьПоискаДублей", ОбластьПоУмолчанию);
	Параметры.Свойство("АдресНастроек", АдресНастроек);
	
	ИнициализироватьСписокОбластейПоискаДублей();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ОбластиПоискаДублейВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ПроизвестиВыбор(ВыбраннаяСтрока);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Выбрать(Команда)
	
	ПроизвестиВыбор(Элементы.ОбластиПоискаДублей.ТекущаяСтрока);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПроизвестиВыбор(Знач ИдентификаторСтроки)
	
	Элемент = ОбластиПоискаДублей.НайтиПоИдентификатору(ИдентификаторСтроки);
	Если Элемент = Неопределено Тогда
		Возврат;
		
	ИначеЕсли Элемент.Значение = ОбластьПоУмолчанию Тогда
		// Не было изменений
		Закрыть();
		Возврат;
		
	КонецЕсли;
	
	ОповеститьОВыборе(Элемент.Значение);
КонецПроцедуры

&НаСервере
Процедура ИнициализироватьСписокОбластейПоискаДублей()
	Если ЗначениеЗаполнено(АдресНастроек)
		И ЭтоАдресВременногоХранилища(АдресНастроек) Тогда
		ТаблицаНастроек = ПолучитьИзВременногоХранилища(АдресНастроек);
	Иначе
		ТаблицаНастроек = ПоискИУдалениеДублей.НастройкиОбъектовМетаданных();
		АдресНастроек = ПоместитьВоВременноеХранилище(ТаблицаНастроек, УникальныйИдентификатор);
	КонецЕсли;
	
	Для Каждого СтрокаТаблицы Из ТаблицаНастроек Цикл
		Элемент = ОбластиПоискаДублей.Добавить(СтрокаТаблицы.ПолноеИмя, СтрокаТаблицы.ПредставлениеСписка, , БиблиотекаКартинок[СтрокаТаблицы.Вид]);
		Если СтрокаТаблицы.ПолноеИмя = ОбластьПоУмолчанию Тогда
			Элементы.ОбластиПоискаДублей.ТекущаяСтрока = Элемент.ПолучитьИдентификатор();
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти