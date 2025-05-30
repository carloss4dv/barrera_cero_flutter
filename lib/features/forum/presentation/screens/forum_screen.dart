import 'package:flutter/material.dart';
import '../../domain/forum_message_model.dart';
import '../../domain/i_forum_service.dart';
import 'package:get_it/get_it.dart';
import '../../../auth/service/auth_service.dart';
import '../../../../services/local_user_storage_service.dart';
import '../../../../widgets/loading_card.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final IForumService _forumService = GetIt.instance<IForumService>();
  final AuthService _authService = GetIt.instance<AuthService>();
  final TextEditingController _messageController = TextEditingController();
  List<ForumMessageModel> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndLoad();
  }

  Future<void> _checkAuthenticationAndLoad() async {
    if (_authService.currentUser == null) {
      // Usuario no autenticado, redirigir al login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return;
    }
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _forumService.getMessages();
    result.fold(
      (messages) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
      },
      (error) {
        setState(() {
          _errorMessage = error.toString();
          _isLoading = false;
        });
      },
    );
  }  Future<void> _addMessage() async {
    if (_messageController.text.isEmpty) return;

    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para publicar mensajes')),
      );
      return;
    }    // Debug: Imprimir información del usuario
    print('Usuario actual:');
    print('- UID: ${user.uid}');
    print('- Email: ${user.email}');
    print('- DisplayName: ${user.displayName}');
    
    // Obtener el nombre del usuario usando la función helper
    final userName = await _getUserName(user);
    print('- Nombre a usar: $userName');final result = await _forumService.addMessage(
      _messageController.text,
      user.uid, // ID de usuario real
      userName, // Usar nombre del usuario
    );

    result.fold(
      (message) {
        setState(() {
          _messages.insert(0, message);
          _messageController.clear();
        });
      },
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foro de Experiencias'),
      ),
      body: Column(
        children: [
          // Campo para escribir mensaje
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu experiencia...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addMessage,
                ),
              ],
            ),
          ),
            // Lista de mensajes
          Expanded(
            child: _isLoading
                ? const Center(
                    child: LoadingCard(
                      message: 'Cargando mensajes del foro...',
                    ),
                  )
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _MessageCard(
                            message: message,                            onComment: (comment) async {
                              final user = _authService.currentUser;
                              if (user == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Debes iniciar sesión para comentar')),
                                );
                                return;
                              }                              // Obtener el nombre del usuario usando la función helper
                              final userName = await _getUserName(user);

                              final result = await _forumService.addComment(
                                message.id,
                                comment,
                                user.uid, // ID de usuario real
                                userName, // Usar nombre del usuario
                              );

                              result.fold(
                                (updatedMessage) {
                                  setState(() {
                                    _messages[index] = updatedMessage;
                                  });
                                },
                                (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.toString())),
                                  );
                                },
                              );
                            },                            onLike: () async {
                              final user = _authService.currentUser;
                              if (user == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Debes iniciar sesión para dar "me gusta"')),
                                );
                                return;
                              }

                              final result = await _forumService.likeMessage(
                                message.id,
                                user.uid, // ID de usuario real
                              );

                              result.fold(
                                (updatedMessage) {
                                  setState(() {
                                    _messages[index] = updatedMessage;
                                  });
                                },
                                (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.toString())),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),    );
  }

  // Función helper para obtener el nombre del usuario
  Future<String> _getUserName(user) async {
    try {
      final retrievedUserName = await localUserStorage.getUserName();
      if (retrievedUserName != null && retrievedUserName.isNotEmpty) {
        return retrievedUserName;
      } else {
        // Si no hay nombre en localStorage, usar el displayName de Firebase o parte del email
        return user.displayName ?? 
               user.email?.split('@').first ?? 
               'Usuario';
      }
    } catch (e) {
      print('Error obteniendo nombre de usuario: $e');
      // Usar fallback de Firebase
      return user.displayName ?? 
             user.email?.split('@').first ?? 
             'Usuario';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class _MessageCard extends StatefulWidget {
  final ForumMessageModel message;
  final Function(String) onComment;
  final VoidCallback onLike;

  const _MessageCard({
    required this.message,
    required this.onComment,
    required this.onLike,
  });

  @override
  State<_MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<_MessageCard> {
  final TextEditingController _commentController = TextEditingController();
  bool _showComments = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado del mensaje
            Row(
              children: [
                CircleAvatar(
                  child: Text(widget.message.userName[0]),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(widget.message.createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Contenido del mensaje
            Text(widget.message.content),
            
            const SizedBox(height: 8),
            
            // Acciones
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: widget.onLike,
                ),
                Text('${widget.message.likes}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () {
                    setState(() {
                      _showComments = !_showComments;
                    });
                  },
                ),
                Text('${widget.message.comments.length}'),
              ],
            ),
            
            // Sección de comentarios
            if (_showComments) ...[
              const Divider(),
              // Campo para escribir comentario
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un comentario...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_commentController.text.isNotEmpty) {
                        widget.onComment(_commentController.text);
                        _commentController.clear();
                      }
                    },
                  ),
                ],
              ),
              
              // Lista de comentarios
              ...widget.message.comments.map((comment) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          child: Text(comment.userName[0]),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          comment.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(comment.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0),
                      child: Text(comment.content),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
} 