class Permission {
  final String resource;
  final List<String> actions;

  Permission({required this.resource, required this.actions});

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      resource: json['resource'] ?? '/*',
      actions:
          json['actions'] != null ? List<String>.from(json['actions']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'resource': resource, 'actions': actions};
  }
}

class City {
  final String? id;
  final String? name;
  final String? postalCode;
  final String? country;

  City({this.id, this.name, this.postalCode, this.country});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
      postalCode: json['postalCode'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'postalCode': postalCode,
      'country': country,
    };
  }
}

/// Represents a user role
class UserRole {
  final String id;
  final String name;
  final List<Permission> permissions;

  UserRole({required this.id, required this.name, required this.permissions});

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      permissions:
          json['permissions'] != null
              ? (json['permissions'] as List)
                  .map((p) => Permission.fromJson(p))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'permissions': permissions.map((p) => p.toJson()).toList(),
    };
  }
}

/// Represents a user in the system
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final List<UserRole> roles;
  final bool archived;
  final String? phoneNumber;
  final String? address;
  final City? city;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.roles,
    required this.archived,
    this.phoneNumber,
    this.address,
    this.city,
  });

  /// Creates a User instance from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      roles:
          json['roles'] != null
              ? (json['roles'] as List)
                  .map((role) => UserRole.fromJson(role))
                  .toList()
              : [],
      archived: json['archived'] ?? false,
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      city: json['city'] != null ? City.fromJson(json['city']) : null,
    );
  }

  /// Converts the User instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'roles': roles.map((role) => role.toJson()).toList(),
      'archived': archived,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city?.toJson(),
    };
  }

  /// Get all permissions across all roles
  List<Permission> get allPermissions =>
      roles.expand((role) => role.permissions).toList();

  /// Check if user has a specific permission
  bool hasPermission(String resource, String action) {
    return allPermissions.any(
      (permission) =>
          permission.resource == resource &&
          permission.actions.contains(action),
    );
  }
}
