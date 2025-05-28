import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../infrastructure/services/distance_tracking_service.dart';

class DistanceTrackingControl extends StatefulWidget {
  const DistanceTrackingControl({Key? key}) : super(key: key);

  @override
  State<DistanceTrackingControl> createState() => _DistanceTrackingControlState();
}

class _DistanceTrackingControlState extends State<DistanceTrackingControl> {
  late DistanceTrackingService _distanceService;
  bool _isTracking = false;
  double _totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() async {
    try {
      _distanceService = GetIt.instance<DistanceTrackingService>();
      
      // Inicializar el servicio
      await _distanceService.initialize();
      
      // Configurar listeners
      _distanceService.trackingStateStream.listen((isTracking) {
        if (mounted) {
          setState(() {
            _isTracking = isTracking;
          });
        }
      });

      _distanceService.distanceStream.listen((distance) {
        if (mounted) {
          setState(() {
            _totalDistance = distance;
          });
        }
      });

      // Obtener estado inicial
      setState(() {
        _isTracking = _distanceService.isTracking;
        _totalDistance = _distanceService.totalDistance;
      });

    } catch (e) {
      print('=== ERROR: Error inicializando DistanceTrackingControl: $e ===');
    }
  }

  Future<void> _toggleTracking() async {
    try {
      if (_isTracking) {
        await _distanceService.stopTracking();
        _showSnackBar('Tracking de distancia detenido', Icons.stop);
      } else {
        final success = await _distanceService.startTracking();
        if (success) {
          _showSnackBar('Tracking de distancia iniciado', Icons.play_arrow);
        } else {
          _showSnackBar('Error al iniciar tracking', Icons.error);
        }
      }
    } catch (e) {
      print('=== ERROR: Error en toggle tracking: $e ===');
      _showSnackBar('Error al cambiar estado del tracking', Icons.error);
    }
  }

  void _showSnackBar(String message, IconData icon) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDebugDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug - Tracking de Distancia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado: ${_isTracking ? "Activo" : "Inactivo"}'),
            Text('Distancia total: ${(_totalDistance / 1000).toStringAsFixed(2)} km'),
            Text('Distancia en metros: ${_totalDistance.toStringAsFixed(0)} m'),
            const SizedBox(height: 16),
            const Text('Acciones de debug:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _distanceService.addTestDistance(500); // 500 metros
              Navigator.of(context).pop();
              _showSnackBar('500m agregados para testing', Icons.add);
            },
            child: const Text('+ 500m'),
          ),
          TextButton(
            onPressed: () async {
              await _distanceService.addTestDistance(1000); // 1 km
              Navigator.of(context).pop();
              _showSnackBar('1 km agregado para testing', Icons.add);
            },
            child: const Text('+ 1km'),
          ),
          TextButton(
            onPressed: () async {
              await _distanceService.resetDistance();
              Navigator.of(context).pop();
              _showSnackBar('Distancia reseteada', Icons.refresh);
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_walk,
                color: theme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Tracking de Distancia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _showDebugDialog,
                icon: const Icon(Icons.bug_report),
                tooltip: 'Debug',
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Información de distancia
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distancia Total',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${(_totalDistance / 1000).toStringAsFixed(2)} km',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Estado',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isTracking ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isTracking ? 'Activo' : 'Inactivo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botón de control
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _toggleTracking,
              icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
              label: Text(_isTracking ? 'Detener Tracking' : 'Iniciar Tracking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTracking ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Información adicional
          Text(
            _isTracking 
              ? 'El tracking está activo. Tu distancia se está registrando.'
              : 'Inicia el tracking para comenzar a registrar tu distancia recorrida.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Los streams se manejan automáticamente por el servicio singleton
    super.dispose();
  }
}