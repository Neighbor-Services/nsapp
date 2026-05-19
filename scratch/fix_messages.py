import re

file_path = 'e:/ns/frontend/nsapp/lib/features/messages/data/datasource/remote/message_remote_datasource_impl.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Update signature return types
content = content.replace('Future<List<ChatMessage>?>', 'Future<List<ChatMessage>>')
content = content.replace('Future<List<Chat>?>', 'Future<List<Chat>>')
content = content.replace('Future<Profile?>', 'Future<Profile>')

# Replace catch blocks
content = re.sub(r'catch\s*\([^)]*\)\s*\{\s*return\s+(false|null);\s*\}', 'catch (e) { rethrow; }', content)
content = re.sub(r'return\s+false;\s*\} catch \(e\) \{', 'throw Exception(\'Failed\');\n    } catch (e) {', content)
content = re.sub(r'return\s+null;\s*\} catch \(e\) \{', 'throw Exception(\'Failed\');\n    } catch (e) {', content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Updated message datasource')
