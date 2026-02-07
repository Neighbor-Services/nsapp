import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/models/service_package.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';

class AddServicePackagePage extends StatefulWidget {
  const AddServicePackagePage({super.key});

  @override
  State<AddServicePackagePage> createState() => _AddServicePackagePageState();
}

class _AddServicePackagePageState extends State<AddServicePackagePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _revisionsController = TextEditingController();
  final TextEditingController _deliveryTimeController =
      TextEditingController(); // In days
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _revisionsController.dispose();
    _deliveryTimeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final package = ServicePackage(
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        revisions: int.tryParse(_revisionsController.text.trim()) ?? 0,
        deliveryTime: int.tryParse(_deliveryTimeController.text.trim()) ?? 0,
        features: [], // Implement features list input if needed, for now empty
      );

      context.read<ProviderBloc>().add(
        AddServicePackageEvent(package: package),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        title: const Text(
          "Add Service Package",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: GradientBackground(
        child: BlocConsumer<ProviderBloc, ProviderState>(
          listener: (context, state) {
            if (state is SuccessAddServicePackageState) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Package added successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is FailureAddServicePackageState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("state.failure.message"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              child: Form(
                key: _formKey,
                child: SolidContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SolidTextField(
                        controller: _nameController,
                        hintText: "Package Name (e.g., Basic)",
                        prefixIcon: Icons.label_outline_rounded,
                        validator: (val) => val!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      SolidTextField(
                        controller: _priceController,
                        hintText: "Price (\u0024)",
                        prefixIcon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                        validator: (val) => val!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      SolidTextField(
                        controller: _descriptionController,
                        hintText: "Description",
                        prefixIcon: Icons.description_outlined,
                        isMultiLine: true,
                        validator: (val) => val!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      SolidTextField(
                        controller: _revisionsController,
                        hintText: "Revisions (Optional)",
                        prefixIcon: Icons.repeat_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      SolidTextField(
                        controller: _deliveryTimeController,
                        hintText: "Delivery Time (Days)",
                        prefixIcon: Icons.timer_outlined,
                        keyboardType: TextInputType.number,
                        validator: (val) => val!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 24),
                      SolidButton(
                        label: "Add Package",
                        isLoading: state is LoadingProviderState,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
