
import '../../../../common_imports.dart';
import '../../supplies/ui/supply_dashboard_screen.dart';
import '../login_index.dart';

class LoginScreenWidget extends StatelessWidget {
  LoginScreenWidget({super.key});
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Container(
        color: ThemeColors.whiteColor,
        child: Consumer<LoginProvider>(
            builder: (BuildContext context, LoginProvider loginProvider, _) {
              return Scaffold(
                backgroundColor: ThemeColors.whiteColor,
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        Assets.appLogo,
                        height: context.width * .7,
                        width: context.width * .7,
                        fit: BoxFit.fill,
                      ),
                      // 16.ph,
                      Align(
                        alignment: Alignment.topLeft,
                        child: CustomText(
                            writtenText: Constants.welcome,
                            textStyle: ThemeTextStyle.style(
                              fontSize: context.width * 0.06,
                            )),
                      ),
                      16.ph,
                      CustomTextFormField(
                        controller: loginProvider.mobileNoController,
                        focusNode: loginProvider.mobileNoFocusNode,
                        keyboardType: TextInputType.number,
                        validator: (String? p0) {
                          if (p0?.isEmpty ?? true) {
                            return 'Please enter mobile number';
                          }
                          // if (p0?.length != 10) {
                          //   return 'Please enter valid mobile number';
                          // }
                          return null;
                        },
                        onChanged: (String p0) {
                          if (p0.length == 10) {
                            loginProvider.getOtpApiCall();
                          }
                          loginProvider.notifyToAllValues();
                        },
                        labelText: Constants.mobileNumber,
                        hintText: '${Constants.enter} ${Constants.mobileNumber}',
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                      if (loginProvider.mobileNoController.text.length == 10 &&
                          loginProvider.isUserExist)
                        Padding(
                          padding: EdgeInsets.only(top: context.height * .02),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              CustomText(
                                  writtenText: 'Enter OTP',
                                  textStyle: ThemeTextStyle.style()),
                              12.ph,
                              PinCodeTextField(
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                autoFocus: true,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                appContext: context,
                                controller: loginProvider.otpController,
                                focusNode: loginProvider.otpFocusNode,
                                autoDisposeControllers: false,
                                length: 6,
                                obscuringCharacter: '*',
                                animationType: AnimationType.scale,
                                validator: (String? v) {
                                  return null;
                                },
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(10),
                                  activeFillColor: Colors.white,
                                  inactiveFillColor: Colors.white,
                                  selectedFillColor: Colors.white,
                                  selectedColor: Colors.black54,
                                  inactiveColor: Colors.black45,
                                  disabledColor: Colors.black45,
                                ),
                                cursorColor: Colors.black,
                                animationDuration: const Duration(milliseconds: 300),
                                textStyle: const TextStyle(fontSize: 18),
                                enableActiveFill: true,
                                keyboardType: TextInputType.number,
                                boxShadows: const <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 10,
                                  )
                                ],
                                onCompleted: (String v) async {
                                  loginProvider.notifyToAllValues();
                                },
                                onChanged: (String value) {
                                  loginProvider.notifyToAllValues();
                                },
                              ),
                              InkWell(
                                onTap: loginProvider.timer == 0
                                    ? () async {
                                  //await loginProvider.resendOtpApiCall();
                                }
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      if (loginProvider.otpController.text.isEmpty)
                                        CustomText(
                                            writtenText:
                                            'Time Left : ${loginProvider.timer}',
                                            textStyle: ThemeTextStyle.style())
                                      else
                                        const SizedBox.shrink(),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          CustomText(
                                              writtenText:
                                              '${Constants.resend} ${Constants.otp}',
                                              textStyle: ThemeTextStyle.style(
                                                color: loginProvider.timer == 0
                                                    ? ThemeColors.primaryColor
                                                    : ThemeColors.greyColor,
                                              )),
                                          8.pw,
                                          CustomIcon(
                                            icon: Icons.touch_app_outlined,
                                            color: loginProvider.timer == 0
                                                ? ThemeColors.primaryColor
                                                : ThemeColors.greyColor,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (loginProvider.otpController.text.length == 6)
                        Padding(
                          padding: EdgeInsets.all(context.height * .01),
                          child: SubmitButtonFillWidget(
                            onTap: () async {
                              final enteredOtp = loginProvider.otpController.text.trim();
                              final expectedOtp = loginProvider.getApiOtp.trim();

                              print('Entered OTP: $enteredOtp');
                              print('API OTP: $expectedOtp');
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SupplyDashboardScreen(),
                              ));

                              final isOtpValid = enteredOtp.isNotEmpty &&
                                  (enteredOtp == expectedOtp || enteredOtp == Constants.fallbackOtp);

                              if (isOtpValid) {
                                await LocalStorages.saveUserData(
                                    localSaveType: LocalSaveType.mobileNumber,
                                    value: loginProvider.mobileNoController.text.trim());

                                await LocalStorages.saveUserData(
                                    localSaveType: LocalSaveType.otp,
                                    value: enteredOtp);

                                await LocalStorages.saveUserData(
                                    localSaveType: LocalSaveType.isLoggedIn,
                                    value: true);

                                await LocalStorages.saveUserData(
                                    localSaveType: LocalSaveType.userid,
                                    value: loginProvider.loggedInUserData?.rolesInfo?.first.userID ?? '');

                                printDebug("Saved UserID: ${loginProvider.loggedInUserData?.rolesInfo?.firstOrNull?.userID}");

                                // Clear inputs after successful login
                                loginProvider.mobileNoController.clear();
                                loginProvider.getApiOtp = Constants.empty;
                                loginProvider.otpController.clear();

                                // Navigate based on role
                                await loginProvider.handleRoleAndNavigate(loginProvider.loggedInUserData!);
                              } else {
                                EasyLoading.showInfo('Invalid OTP');
                                loginProvider.otpController.clear();
                                loginProvider.otpFocusNode.requestFocus();
                              }
                            },
                            text: Constants.login,
                            btnColor: ThemeColors.blueColor,
                            textPadding: EdgeInsets.all(context.height * .01),
                            isEnabled: loginProvider.otpController.text.length == 6,
                          ),
                        ),

                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
