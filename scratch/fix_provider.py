import re

file_path = 'e:/ns/frontend/nsapp/lib/features/provider/data/repository/provider_repository_impl.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if "import 'package:nsapp/core/models/failure.dart';" in line:
        new_lines.append(line)
        new_lines.append("import 'package:nsapp/core/helpers/error_handler.dart';\n")
    elif 'return Left(Failure(message: "An error occurred"));' in line:
        new_lines.append(line.replace('return Left(Failure(message: "An error occurred"));', 'return Left(ErrorHandler.handle(e));'))
    else:
        new_lines.append(line)

content = "".join(new_lines)

# Remove the null checks
content = re.sub(r'if\s*\(results\s*!=\s*null\)\s*\{\s*return\s+Right\(results\);\s*\}\s*return\s+Left\(ErrorHandler\.handle\(e\)\);', r'return Right(results);', content)
content = re.sub(r'if\s*\(results\s*!=\s*null\)\s*\{([\s\S]*?)\}\s*return\s+Left\(ErrorHandler\.handle\(e\)\);', r'\1', content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Updated provider repository')
