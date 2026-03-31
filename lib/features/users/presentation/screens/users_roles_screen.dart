import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:afrocards_admin/config/theme.dart';
import 'package:afrocards_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:afrocards_admin/features/users/data/models/user_admin_model.dart';
import 'package:afrocards_admin/features/users/presentation/bloc/users_bloc.dart';

class UsersRolesScreen extends StatefulWidget {
  const UsersRolesScreen({super.key});

  @override
  State<UsersRolesScreen> createState() => _UsersRolesScreenState();
}

class _UsersRolesScreenState extends State<UsersRolesScreen> {
  final TextEditingController _searchController = TextEditingController();

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
          
          // Table des utilisateurs
          Expanded(
            child: _buildUsersTable(),
          ),
          
          // Bouton Enregistrer
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Gestion des Utilisateurs',
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
        _buildFilterButton(),
        const SizedBox(width: 12),
        
        // Export
        _buildIconButton(
          icon: LucideIcons.mail,
          onTap: () {},
          tooltip: 'Envoyer un email groupé',
        ),
      ],
    );
  }

  Widget _buildFilterButton() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.filter, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Icon(LucideIcons.chevronDown, size: 16, color: Colors.grey.shade600),
        ],
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

  Widget _buildUsersTable() {
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
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // En-tête du tableau
              _buildTableHeader(),
              
              // Corps du tableau
              Expanded(
                child: state.users.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        itemCount: state.users.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          return _buildUserRow(state.users[index], state);
                        },
                      ),
              ),
              
              // Footer avec pagination
              _buildTableFooter(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5)),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(width: 60, child: Text('Img', style: _headerStyle)),
          SizedBox(width: 80, child: Text('Id', style: _headerStyle)),
          Expanded(flex: 2, child: Text('Username', style: _headerStyle)),
          Expanded(flex: 3, child: Text('Email', style: _headerStyle)),
          SizedBox(width: 100, child: Text('Pays', style: _headerStyle)),
          SizedBox(width: 100, child: Text('Statistics', style: _headerStyle)),
          SizedBox(width: 160, child: Text('Rôle Actuel', style: _headerStyle)),
          SizedBox(width: 80, child: Text('Actions', style: _headerStyle)),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppTheme.textSecondary,
  );

  Widget _buildUserRow(UserAdmin user, UsersState state) {
    // Vérifier si ce user a un changement en attente
    final pendingRole = state.pendingRoleChanges[user.id];
    final currentRole = pendingRole ?? user.typeUtilisateur;
    final hasChange = pendingRole != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: hasChange ? AppTheme.primaryYellow.withOpacity(0.05) : null,
      child: Row(
        children: [
          // Avatar
          SizedBox(
            width: 60,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
              backgroundImage: user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
              child: user.avatar.isEmpty
                  ? Text(
                      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppTheme.primaryYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          
          // ID
          SizedBox(
            width: 80,
            child: Text(
              '#${user.id}',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          
          // Username
          Expanded(
            flex: 2,
            child: Text(
              user.displayName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          
          // Email
          Expanded(
            flex: 3,
            child: Text(
              user.email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          
          // Pays
          SizedBox(
            width: 100,
            child: Text(
              user.pays,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          
          // Statistics (mini graph)
          SizedBox(
            width: 100,
            child: _buildMiniStats(user),
          ),
          
          // Rôle Actuel (Dropdown)
          SizedBox(
            width: 160,
            child: _buildRoleDropdown(user, currentRole),
          ),
          
          // Actions
          SizedBox(
            width: 80,
            child: _buildActionButtons(user),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(UserAdmin user) {
    // Récupérer les permissions de l'utilisateur connecté
    final authState = context.read<AuthBloc>().state;
    final canDelete = authState is AuthAuthenticated ? authState.user.canDelete : false;

    return Row(
      children: [
        // Voir - tout le monde peut voir
        _buildActionButton(
          icon: LucideIcons.eye,
          color: AppTheme.primaryGreen,
          onTap: () => _showUserDetails(user),
          tooltip: 'Voir détails',
        ),
        const SizedBox(width: 8),
        // Supprimer - seulement pour admin
        if (canDelete)
          _buildActionButton(
            icon: LucideIcons.trash2,
            color: AppTheme.primaryRed,
            onTap: () => _showDeleteConfirmation(user),
            tooltip: 'Supprimer',
          ),
      ],
    );
  }

  Widget _buildRoleDropdown(UserAdmin user, String currentRole) {
    // Récupérer les permissions de l'utilisateur connecté
    final authState = context.read<AuthBloc>().state;
    final canChangeRoles = authState is AuthAuthenticated ? authState.user.canChangeRoles : false;

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _getRoleColor(currentRole).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getRoleColor(currentRole).withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentRole,
          isExpanded: true,
          icon: Icon(
            LucideIcons.chevronDown,
            size: 16,
            color: _getRoleColor(currentRole),
          ),
          style: TextStyle(
            fontSize: 13,
            color: _getRoleColor(currentRole),
            fontWeight: FontWeight.w500,
          ),
          items: [
            _buildRoleDropdownItem('admin', 'Administrateur'),
            _buildRoleDropdownItem('moderateur', 'Modérateur'),
            _buildRoleDropdownItem('joueur', 'Joueur'),
            _buildRoleDropdownItem('partenaire', 'Partenaire'),
          ],
          // Désactivé pour les modérateurs
          onChanged: canChangeRoles ? (newRole) {
            if (newRole != null) {
              context.read<UsersBloc>().add(UsersLocalRoleChanged(
                userId: user.id,
                newRole: newRole,
              ));
            }
          } : null,
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildRoleDropdownItem(String value, String label) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getRoleColor(value),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppTheme.primaryRed;
      case 'moderateur':
        return Colors.orange;
      case 'partenaire':
        return Colors.purple;
      default:
        return AppTheme.primaryGreen;
    }
  }

  Widget _buildMiniStats(UserAdmin user) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMiniProgressBar(
                value: user.partiesGagnees / (user.partiesJouees > 0 ? user.partiesJouees : 1),
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 4),
              _buildMiniProgressBar(
                value: (user.niveau / 100).clamp(0.0, 1.0),
                color: AppTheme.primaryYellow,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniProgressBar({required double value, required Color color}) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
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
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
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

  Widget _buildTableFooter(UsersState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5E5)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bouton page précédente
          if (state.currentPage > 1)
            TextButton.icon(
              onPressed: () {
                context.read<UsersBloc>().add(UsersLoadRequested(
                  page: state.currentPage - 1,
                  search: state.search,
                ));
              },
              icon: const Icon(LucideIcons.chevronLeft, size: 16),
              label: const Text('Précédent'),
            ),
          
          const SizedBox(width: 16),
          
          // Indicateur pages
          Text(
            'Page ${state.currentPage} sur ${state.totalPages}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Bouton Voir tout / page suivante
          if (state.currentPage < state.totalPages)
            TextButton.icon(
              onPressed: () {
                context.read<UsersBloc>().add(UsersLoadRequested(
                  page: state.currentPage + 1,
                  search: state.search,
                ));
              },
              icon: const Row(
                children: [
                  Text('•••'),
                  SizedBox(width: 8),
                ],
              ),
              label: const Text('Voir tout'),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    // Récupérer les permissions de l'utilisateur connecté
    final authState = context.read<AuthBloc>().state;
    final canChangeRoles = authState is AuthAuthenticated ? authState.user.canChangeRoles : false;

    // Le modérateur ne voit pas le bouton d'enregistrement
    if (!canChangeRoles) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.only(top: 24),
          child: Center(
            child: SizedBox(
              width: 280,
              height: 50,
              child: ElevatedButton(
                onPressed: state.hasPendingChanges && !state.isSubmitting
                    ? () {
                        context.read<UsersBloc>().add(const UsersRoleChangesSubmitted());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Modifications enregistrées avec succès'),
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.hasPendingChanges
                      ? AppTheme.primaryRed
                      : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Enregistrer les Changements',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (state.hasPendingChanges) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${state.pendingRoleChanges.length}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Dialogs
  void _showUserDetails(UserAdmin user) {
    showDialog(
      context: context,
      builder: (context) => _UserDetailsDialog(user: user),
    );
  }

  void _showDeleteConfirmation(UserAdmin user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer l\'utilisateur "${user.displayName}" ?'),
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
}

// Dialog pour voir les détails d'un utilisateur
class _UserDetailsDialog extends StatelessWidget {
  final UserAdmin user;

  const _UserDetailsDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
            backgroundImage: user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
            child: user.avatar.isEmpty
                ? Text(
                    user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppTheme.primaryYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.displayName),
              Text(
                user.roleLabel,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('ID', '#${user.id}'),
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Pays', user.pays),
            _buildDetailRow('Niveau', '${user.niveau}'),
            _buildDetailRow('XP', '${user.xp}'),
            _buildDetailRow('Parties jouées', '${user.partiesJouees}'),
            _buildDetailRow('Parties gagnées', '${user.partiesGagnees}'),
            _buildDetailRow('Classement', user.ranking > 0 ? '#${user.ranking}' : 'Non classé'),
            _buildDetailRow('Statut', user.statutCompte),
            _buildDetailRow('Inscrit le', _formatDate(user.dateCreation)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
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
