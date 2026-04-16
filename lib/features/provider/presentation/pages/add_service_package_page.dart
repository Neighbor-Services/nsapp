import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/models/service_package.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/core/core.dart';


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
            margin: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: context.appColors.glassBorder,
                width: 1.5.r,
              ),
            ),
            child: Icon(
              FontAwesomeIcons.chevronLeft,
              color: context.appColors.primaryTextColor,
              size: 18.r,
            ),
          ),
        ),
        title: Text(
          "ADD SERVICE PACKAGE",
          style: TextStyle(
            color: context.appColors.primaryTextColor,
            fontWeight: FontWeight.w900,
            fontSize: 16.sp,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: GradientBackground(
        child: BlocConsumer<ProviderBloc, ProviderState>(
          listener: (context, state) {
            if (state is SuccessAddServicePackageState) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                  content: Text("Package added successfully"),
                  backgroundColor: context.appColors.successColor,
                ),
              );
            } else if (state is FailureAddServicePackageState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("state.failure.message"),
                  backgroundColor: context.appColors.errorColor,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 100.h, 16.w, 16.h),
              child: Form(
                key: _formKey,
                child: SolidContainer(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      SolidTextField(
                        controller: _nameController,
                        hintText: "Package Name (e.g., Basic)",
                        prefixIcon: FontAwesomeIcons.tag,
                        validator: (val) => val!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 16.h),
                      SolidTextField(
                        controller: _priceController,
                        hintText: "Price (\u0024)",
                        prefixIcon: FontAwesomeIcons.dollarSign,
                        keyboardType: TextInputType.number,
                        validator: (val) => val!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 16.h),
                      SolidTextField(
                        controller: _descriptionController,
                        hintText: "Description",
                        prefixIcon: FontAwesomeIcons.fileLines,
                        isMultiLine: true,
                        validator: (val) => val!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 16.h),
                      SolidTextField(
                        controller: _revisionsController,
                        hintText: "Revisions (Optional)",
                        prefixIcon: FontAwesomeIcons.repeat,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16.h),
                      SolidTextField(
                        controller: _deliveryTimeController,
                        hintText: "Delivery Time (Days)",
                        prefixIcon: FontAwesomeIcons.clock,
                        keyboardType: TextInputType.number,
                        validator: (val) => val!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 24.h),
                      SolidButton(
                        label: "ADD PACKAGE",
                        allCaps: true,
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


