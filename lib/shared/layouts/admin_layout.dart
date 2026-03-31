import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:afrocards_admin/config/theme.dart';
import 'package:afrocards_admin/features/auth/presentation/bloc/auth_bloc.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightBg,
        body: Row(
          children: [
            // Sidebar
            const _Sidebar(),
            
            // Main content
            Expanded(
              child: Column(
                children: [
                  // Top bar
                  const _TopBar(),
                  
                  // Content
                  Expanded(
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Image.asset(
                  'assets/logo_afc.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryGreen, AppTheme.primaryYellow, AppTheme.primaryRed],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.map, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(text: 'AFRO', style: TextStyle(color: AppTheme.primaryGreen)),
                      TextSpan(text: 'CARDS', style: TextStyle(color: AppTheme.primaryRed)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              children: [
                _SidebarItem(
                  icon: LucideIcons.home,
                  label: 'Accueil',
                  path: '/',
                  currentPath: currentPath,
                ),
                _SidebarExpandableItem(
                  icon: LucideIcons.clipboardList,
                  label: 'Questionnaires',
                  currentPath: currentPath,
                  children: [
                    _SidebarSubItem(label: 'Questions', path: '/questions', currentPath: currentPath),
                    _SidebarSubItem(label: 'Catégories', path: '/categories', currentPath: currentPath),
                  ],
                ),
                _SidebarItem(
                  icon: LucideIcons.calendar,
                  label: 'Evenements',
                  path: '/challenges',
                  currentPath: currentPath,
                ),
                _SidebarItem(
                  icon: LucideIcons.disc,
                  label: 'Roue magique',
                  path: '/wheel',
                  currentPath: currentPath,
                ),
                _SidebarItem(
                  icon: LucideIcons.store,
                  label: 'Boutique',
                  path: '/shop',
                  currentPath: currentPath,
                ),
                _SidebarExpandableItem(
                  icon: LucideIcons.users,
                  label: 'Gestion Utilisateurs',
                  currentPath: currentPath,
                  children: [
                    _SidebarSubItem(label: 'Liste des Utili...', path: '/users', currentPath: currentPath),
                    _SidebarSubItem(label: 'Gestion des Rôles', path: '/users/roles', currentPath: currentPath),
                  ],
                ),
              ],
            ),
          ),
          
          // Logout button
          Container(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: const Row(
                  children: [
                    Icon(LucideIcons.logOut, size: 20, color: AppTheme.textSecondary),
                    SizedBox(width: 12),
                    Text(
                      'Se déconnecter',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final String currentPath;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentPath == path;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isActive ? AppTheme.lightBg : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.go(path),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarExpandableItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String currentPath;
  final List<_SidebarSubItem> children;

  const _SidebarExpandableItem({
    required this.icon,
    required this.label,
    required this.currentPath,
    required this.children,
  });

  @override
  State<_SidebarExpandableItem> createState() => _SidebarExpandableItemState();
}

class _SidebarExpandableItemState extends State<_SidebarExpandableItem> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    // Auto-expand if current path is in children
    _isExpanded = widget.children.any((child) => widget.currentPath == child.path);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                    size: 16,
                    color: AppTheme.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isExpanded) ...widget.children,
      ],
    );
  }
}

class _SidebarSubItem extends StatelessWidget {
  final String label;
  final String path;
  final String currentPath;

  const _SidebarSubItem({
    required this.label,
    required this.path,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentPath == path;

    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 2, bottom: 2, right: 4),
      child: Material(
        color: isActive ? AppTheme.lightBg : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.go(path),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Greeting
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String name = 'Admin';
              if (state is AuthAuthenticated) {
                name = state.user.displayName;
              }
              return Text(
                'Bonjour $name!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              );
            },
          ),
          
          const SizedBox(width: 32),
          
          // Search bar
          Container(
            width: 300,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.lightBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.search, size: 18, color: Colors.grey.shade400),
                const SizedBox(width: 12),
                Text(
                  'Rechercher...',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Messages
          IconButton(
            icon: const Icon(LucideIcons.mail, color: AppTheme.textSecondary),
            onPressed: () {},
          ),
          
          const SizedBox(width: 8),
          
          // Notifications
          IconButton(
            icon: const Icon(LucideIcons.bell, color: AppTheme.textSecondary),
            onPressed: () {},
          ),
          
          const SizedBox(width: 16),
          
          // User profile
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String? avatarUrl;
              if (state is AuthAuthenticated) {
                avatarUrl = state.user.avatarURL;
              }
              return PopupMenuButton<String>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(LucideIcons.user, size: 18),
                        SizedBox(width: 12),
                        Text('Mon profil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(LucideIcons.settings, size: 18),
                        SizedBox(width: 12),
                        Text('Paramètres'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(LucideIcons.logOut, size: 18, color: AppTheme.error),
                        SizedBox(width: 12),
                        Text('Déconnexion', style: TextStyle(color: AppTheme.error)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  } else if (value == 'settings') {
                    context.go('/settings');
                  }
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.2),
                      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
                          ? const Text('A', style: TextStyle(color: AppTheme.primaryPurple))
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Icon(LucideIcons.chevronDown, size: 16, color: AppTheme.textSecondary),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
