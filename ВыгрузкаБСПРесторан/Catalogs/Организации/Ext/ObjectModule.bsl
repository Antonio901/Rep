﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	//Если Не ЭтоГруппа И Не Константы.ИспользоватьНесколькоОрганизаций.Получить()
	//	И Справочники.Организации.КоличествоОрганизаций() > 1 Тогда
	//	
	//	УстановитьПривилегированныйРежим(Истина);
	//	Константы.ИспользоватьНесколькоОрганизаций.Установить(Истина);
	//	УстановитьПривилегированныйРежим(Ложь);
	//	
	//КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
