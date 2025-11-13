import 'package:flutter/material.dart';

class NavItem {
  final Widget page;
  final IconData icon;
  final String label;

  const NavItem({
    required this.page,
    required this.icon,
    required this.label,
  });
}
