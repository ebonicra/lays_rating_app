import 'package:flutter/material.dart';

// Тип чипса: классические, рифленные, из печи и т.д. и описание для карточек фильтров
enum ChipType {
  classic('classic', 'Классические', 'Тонкие, солёные, хрустящие', Icons.circle),
  ridged('ridged', 'Рифленные', 'Чипсы с большими рёбрами', Icons.waves),
  baked('baked', 'Из печи', 'Запечённые чипсы, псевдо-пп', Icons.bakery_dining),
  maxx('maxx', 'Maxx', 'Большие чипсы с большими горами', Icons.terrain),
  stax('stax', 'Stax', 'Чипсы в тубусе, закос под Pringles', Icons.inventory_2),
  stix('stix', 'Stix', 'Палочки. Кто-то их любит?', Icons.drag_handle);

  final String value;
  final String title;
  final String description;
  final IconData icon;

  const ChipType(
    this.value,
    this.title,
    this.description,
    this.icon,
  );
}