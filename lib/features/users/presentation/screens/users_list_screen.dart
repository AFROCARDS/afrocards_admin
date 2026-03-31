import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:afrocards_admin/config/theme.dart';
import 'package:afrocards_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:afrocards_admin/features/users/data/models/user_admin_model.dart';
import 'package:afrocards_admin/features/users/presentation/bloc/users_bloc.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(const UsersLoadRequested(refresh: true));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<UsersBloc>().add(UsersLoadRequested(
      refresh: true,
      search: _searchController.text,
      typeFilter: _selectedFilter,
    ));
  }

  void _onFilterChanged(String? filter) {
    setState(() => _selectedFilter = filter);
    context.read<UsersBloc>().add(UsersLoadRequested(
      refresh: true,
      typeFilter: filter,
      search: _searchController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et actions
          _buildHeader(),
          const SizedBox(height: 24),
          
          // Liste des joueurs
          Expanded(
            child: _buildPlayersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Liste des Utilisateurs',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const Spacer(),
        
        // Barre de recherche
        Container(
          width: 250,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(LucideIcons.search, size: 18, color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onSubmitted: (_) => _onSearch(),
          ),
        ),
        const SizedBox(width: 12),
        
        // Filtres
        _buildFilterDropdown(),
        const SizedBox(width: 12),
        
        // Refresh
        _buildIconButton(
          icon: LucideIcons.refreshCw,
          onTap: () => context.read<UsersBloc>().add(const UsersLoadRequested(refresh: true)),
          tooltip: 'Actualiser',
        ),
      ],
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedFilter,
          hint: Row(
            children: [
              Icon(LucideIcons.filter, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text('Filtrer', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            ],
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('Tous')),
            DropdownMenuItem(value: 'joueur', child: Text('Joueurs')),
            DropdownMenuItem(value: 'admin', child: Text('Admins')),
            DropdownMenuItem(value: 'moderateur', child: Text('Modérateurs')),
            DropdownMenuItem(value: 'partenaire', child: Text('Partenaires')),
          ],
          onChanged: _onFilterChanged,
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: Icon(icon, size: 18, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildPlayersList() {
    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, state) {
        if (state.status == UsersStatus.loading && state.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == UsersStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.alertCircle, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(state.errorMessage ?? 'Une erreur est survenue'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<UsersBloc>().add(const UsersLoadRequested(refresh: true)),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E5E5)),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.users, size: 20, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    const Text(
                      'Joueurs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${state.totalUsers} utilisateurs',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Liste des joueurs
              Expanded(
                child: state.users.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: state.users.length,
                        itemBuilder: (context, index) {
                          return _PlayerListItem(
                            user: state.users[index],
                            index: index,
                            onView: () => _showUserDetails(state.users[index]),
                            onEdit: () => _showEditDialog(state.users[index]),
                            onDelete: () => _showDeleteConfirmation(state.users[index]),
                            onEmail: () => _sendEmail(state.users[index]),
                          );
                        },
                      ),
              ),
              
              // Footer avec pagination
              _buildPagination(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.users, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Aucun utilisateur trouvé',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(UsersState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5E5)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.currentPage > 1)
            TextButton.icon(
              onPressed: () {
                context.read<UsersBloc>().add(UsersLoadRequested(
                  page: state.currentPage - 1,
                  typeFilter: state.typeFilter,
                  search: state.search,
                ));
              },
              icon: const Icon(LucideIcons.chevronLeft, size: 16),
              label: const Text('Précédent'),
            ),
          
          const SizedBox(width: 16),
          
          Text(
            'Page ${state.currentPage} sur ${state.totalPages}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(width: 16),
          
          if (state.currentPage < state.totalPages)
            TextButton(
              onPressed: () {
                context.read<UsersBloc>().add(UsersLoadRequested(
                  page: state.currentPage + 1,
                  typeFilter: state.typeFilter,
                  search: state.search,
                ));
              },
              child: const Row(
                children: [
                  Text('Voir plus'),
                  SizedBox(width: 4),
                  Icon(LucideIcons.chevronRight, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showUserDetails(UserAdmin user) {
    showDialog(
      context: context,
      builder: (context) => _UserDetailsDialog(user: user),
    );
  }

  void _showEditDialog(UserAdmin user) {
    final authState = context.read<AuthBloc>().state;
    final canEdit = authState is AuthAuthenticated ? authState.user.canEdit : false;
    if (!canEdit) return;

    showDialog(
      context: context,
      builder: (ctx) => _UserEditDialog(user: user, bloc: context.read<UsersBloc>()),
    );
  }

  void _showDeleteConfirmation(UserAdmin user) {
    final authState = context.read<AuthBloc>().state;
    final canDelete = authState is AuthAuthenticated ? authState.user.canDelete : false;
    if (!canDelete) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${user.displayName}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            onPressed: () {
              context.read<UsersBloc>().add(UsersDeleteRequested(user.id));
              Navigator.pop(ctx);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _sendEmail(UserAdmin user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Envoi d\'email à ${user.email}')),
    );
  }
}

// ============================================
// PLAYER LIST ITEM (Style Top Joueurs)
// ============================================

class _PlayerListItem extends StatelessWidget {
  final UserAdmin user;
  final int index;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onEmail;

  const _PlayerListItem({
    required this.user,
    required this.index,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    // Couleurs selon le rang
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
      AppTheme.textMuted,
      AppTheme.textMuted,
    ];

    final authState = context.read<AuthBloc>().state;
    final canEdit = authState is AuthAuthenticated ? authState.user.canEdit : false;
    final canDelete = authState is AuthAuthenticated ? authState.user.canDelete : false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: index < 3 ? colors[index].withValues(alpha: 0.08) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: index < 3 
            ? Border.all(color: colors[index].withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        children: [
          // Rang
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors[index < 5 ? index : 4],
              shape: BoxShape.circle,
            ),
            child: Text(
              '${user.ranking > 0 ? user.ranking : index + 1}',
              style: TextStyle(
                color: index < 3 ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundImage: user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
            backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
            child: user.avatar.isEmpty
                ? Text(
                    user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          
          // Infos joueur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildRoleBadge(user.typeUtilisateur),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.mail, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.star, size: 14, color: AppTheme.primaryYellow),
                const SizedBox(width: 4),
                Text(
                  'Niv. ${user.niveau}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.primaryYellow,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Pays
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.mapPin, size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  user.pays,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // XP / Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_formatScore(user.xp)} XP',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canEdit)
                _buildActionButton(
                  icon: LucideIcons.pencil,
                  color: AppTheme.primaryYellow,
                  onTap: onEdit,
                  tooltip: 'Modifier',
                ),
              if (canEdit) const SizedBox(width: 8),
              
              _buildActionButton(
                icon: LucideIcons.eye,
                color: AppTheme.primaryGreen,
                onTap: onView,
                tooltip: 'Voir détails',
              ),
              const SizedBox(width: 8),
              
              if (canDelete)
                _buildActionButton(
                  icon: LucideIcons.trash2,
                  color: AppTheme.primaryRed,
                  onTap: onDelete,
                  tooltip: 'Supprimer',
                ),
              if (canDelete) const SizedBox(width: 8),
              
              _buildActionButton(
                icon: LucideIcons.mail,
                color: Colors.blue,
                onTap: onEmail,
                tooltip: 'Email',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color color;
    String label;
    
    switch (role) {
      case 'admin':
        color = AppTheme.primaryRed;
        label = 'Admin';
        break;
      case 'moderateur':
        color = Colors.orange;
        label = 'Modérateur';
        break;
      case 'partenaire':
        color = Colors.purple;
        label = 'Partenaire';
        break;
      default:
        color = AppTheme.primaryGreen;
        label = 'Joueur';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }

  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}k';
    }
    return score.toString();
  }
}

// ============================================
// DIALOGS
// ============================================

class _UserEditDialog extends StatefulWidget {
  final UserAdmin user;
  final UsersBloc bloc;

  const _UserEditDialog({required this.user, required this.bloc});

  @override
  State<_UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<_UserEditDialog> {
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.user.statutCompte;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Modifier ${widget.user.displayName}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Statut du compte', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'actif', child: Text('Actif')),
                DropdownMenuItem(value: 'suspendu', child: Text('Suspendu')),
                DropdownMenuItem(value: 'supprime', child: Text('Supprimé')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _selectedStatus = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
          onPressed: () {
            widget.bloc.add(UsersStatusUpdateRequested(
              userId: widget.user.id,
              newStatus: _selectedStatus,
            ));
            Navigator.pop(context);
          },
          child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _UserDetailsDialog extends StatelessWidget {
  final UserAdmin user;

  const _UserDetailsDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
            backgroundImage: user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
            child: user.avatar.isEmpty
                ? Text(
                    user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 4),
                _buildRoleBadge(user.typeUtilisateur),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(LucideIcons.hash, 'ID', '#${user.id}'),
            _buildInfoRow(LucideIcons.mail, 'Email', user.email),
            _buildInfoRow(LucideIcons.mapPin, 'Pays', user.pays),
            _buildInfoRow(LucideIcons.star, 'Niveau', '${user.niveau}'),
            _buildInfoRow(LucideIcons.zap, 'XP', '${user.xp}'),
            _buildInfoRow(LucideIcons.gamepad2, 'Parties jouées', '${user.partiesJouees}'),
            _buildInfoRow(LucideIcons.trophy, 'Parties gagnées', '${user.partiesGagnees}'),
            _buildInfoRow(LucideIcons.award, 'Classement', user.ranking > 0 ? '#${user.ranking}' : 'Non classé'),
            _buildInfoRow(LucideIcons.shieldCheck, 'Statut', user.statutCompte),
            _buildInfoRow(LucideIcons.calendar, 'Inscrit le', _formatDate(user.dateCreation)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    Color color;
    String label;
    
    switch (role) {
      case 'admin':
        color = AppTheme.primaryRed;
        label = 'Administrateur';
        break;
      case 'moderateur':
        color = Colors.orange;
        label = 'Modérateur';
        break;
      case 'partenaire':
        color = Colors.purple;
        label = 'Partenaire';
        break;
      default:
        color = AppTheme.primaryGreen;
        label = 'Joueur';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
