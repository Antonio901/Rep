﻿#Область ОбработчикиСобытий

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	ТекстНапоминания = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '""%1"" требует внимания'"), ПараметрКоманды);
	НапоминанияПользователяКлиент.НапомнитьВУказанноеВремя(ТекстНапоминания,
		ОбщегоНазначенияКлиент.ДатаСеанса() + 10*60,
		ПараметрКоманды);
		
	ПоказатьОповещениеПользователя(НСтр("ru = 'Создано напоминание:'"), , ТекстНапоминания, БиблиотекаКартинок.Информация32);
КонецПроцедуры

#КонецОбласти
