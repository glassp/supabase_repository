# Supabase Database Adapter for Dart
[![Pub Version](https://img.shields.io/pub/v/supabase_repository)](https://pub.dev/packages/supabase_repository)

Use this database adapter for supabase to integrate with database_repository

## How to install
```bash
dart pub add supabase_repository
```

## How to use
```dart
void main() {
    final String mySupabaseUrl = /* String containing the URL of the Supabase Installation */
    final String mySupabaseKey = /* String containing the API Key for the Supabase Installation */
    final DatabaseAdapter myDatabaseAdapter = SupabaseDatabaseAdapter(
        supabaseInstallationUrl: mySupabaseUrl,
        supabaseApiKey: mySupabaseKey
    );
    
    // Register a Database Adapter that you want to use.
    DatabaseAdapterRegistry.register(myDatabaseAdapter);

    final repository = DatabaseRepository.fromRegistry(serializer: mySerializer, name: 'supabase');
    
    // Now use some methods such as create() etc.
}
```
