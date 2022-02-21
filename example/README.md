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