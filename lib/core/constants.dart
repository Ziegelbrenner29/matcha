// lib/core/constants.dart
import 'package:flutter/material.dart';

const double timingWindowMs = 80.0;         // ±80ms wie im echten Spiel
const Duration fakeTouchDuration = Duration(milliseconds: 300); // Fake-Berührung
const int maxFakesInARow = 2;               // Verhindert Endlosschleifen

// Portrait Hit-Zonen (prozentual – passt auf allen Geräten)
const double upperHandZoneRatio = 0.33;     // oberes Drittel = Gegner/KI
const double bowlZoneHeightRatio = 0.34;    // mittleres Drittel + etwas Überlapp
const double lowerHandZoneRatio = 0.33;     // unteres Drittel = Spieler 1

// Sounds (müssen exakt so in assets/audio/ liegen)
const String soundTok = 'audio/tok.wav';
const String soundPon = 'audio/pon.wav';
const String soundDon = 'audio/don.wav';
const String soundWind = 'audio/wind.mp3';
const String soundKonpira = 'assets/audio/konpira_fune_fune.mp3';
const String soundMatchaPon = 'audio/matcha_pon.mp3';