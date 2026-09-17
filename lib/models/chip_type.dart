import 'package:flutter/material.dart';


enum ChipType {
  classic(
    "classic",
    "Классические",
    "Соленая классика.",
    Icons.circle,
  ),

  ridged(
    "ridged",
    "Рифленные",
    "Чипсы с большими хрустящими ребрами.",
    Icons.waves,
  ),

  baked(
    "baked",
    "Из печи",
    "Запеченные чипсы.",
    Icons.bakery_dining,
  ),

  maxx(
    "maxx",
    "Maxx",
    "Большие чипсы с большими горами.",
    Icons.local_fire_department,
  ),

  stax(
    "stax",
    "Stax",
    "Чипсы в тубусе, закос под Pringles.",
    Icons.inventory_2,
  ),

  stix(
    "stix",
    "Stix",
    "Палочки. Кто-то их любит?",
    Icons.straighten,
  );



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