import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/data_models.dart';

/// A simplified Blockchain simulator for medical record storage.
/// In a production app, this would interact with a real Ethereum/Solana node.
class BlockchainService {
  final List<Block> _chain = [];

  BlockchainService() {
    _createGenesisBlock();
  }

  void _createGenesisBlock() {
    _chain.add(Block(
      index: 0,
      timestamp: DateTime.now().toIso8601String(),
      data: "Genesis Block - MediConnect Immutable Storage",
      previousHash: "0",
      hash: _calculateHash(0, "0", DateTime.now().toIso8601String(), "Genesis Block"),
    ));
  }

  Future<String> recordAssessment(HealthAssessment assessment) async {
    // Simulate complex blockchain processing
    await Future.delayed(const Duration(milliseconds: 800));
    
    final lastBlock = _chain.last;
    final index = lastBlock.index + 1;
    final timestamp = DateTime.now().toIso8601String();
    final data = jsonEncode({
      'assessment_id': assessment.id,
      'condition': assessment.possibleCondition,
      'risk': assessment.riskLevel.name,
      'patient_hash': sha256.convert(utf8.encode(assessment.date.toIso8601String())).toString(),
    });
    
    final hash = _calculateHash(index, lastBlock.hash, timestamp, data);
    
    final newBlock = Block(
      index: index,
      timestamp: timestamp,
      data: data,
      previousHash: lastBlock.hash,
      hash: hash,
    );
    
    _chain.add(newBlock);
    return hash; // This is the transaction ID / Block Hash
  }

  String _calculateHash(int index, String previousHash, String timestamp, String data) {
    final raw = "$index$previousHash$timestamp$data";
    return sha256.convert(utf8.encode(raw)).toString();
  }

  List<Block> getChain() => List.unmodifiable(_chain);
}

class Block {
  final int index;
  final String timestamp;
  final String data;
  final String previousHash;
  final String hash;

  Block({
    required this.index,
    required this.timestamp,
    required this.data,
    required this.previousHash,
    required this.hash,
  });
}
