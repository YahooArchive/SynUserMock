#!/bin/sh
set -e

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcassets)
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
install_resource "BouncerSDK/BouncerSDK/Bouncer.xcassets"
install_resource "BouncerSDK/BouncerSDK/BouncerSigninTableViewCell.xib"
install_resource "BouncerSDK/BouncerSDK/BouncerSigninViewController.xib"
install_resource "BouncerSDK/BouncerSDK/BouncerWebSigninViewController.xib"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/YAccounts2LCAnswerViewController.xib"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/YAccounts2LCQuestionViewController.xib"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/YAccounts2LCSelectChannelViewController.xib"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/YAccounts3PAMigratorViewController.xib"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/YAccountsAccountRecoveryViewController.xib"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/YAccountsAttSignupViewController.xib"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/YAccountsGenericHandoffViewController.xib"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/YAccountsPasswordViewController.xib"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/YAccountsRemoveAccountAlertView.xib"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/YAccountsSignInViewController.xib"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/YAccountsSignUpViewController.xib"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/YAccountsSSOViewController.xib"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/YAccountsUnlockAccountViewController.xib"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/YAccountsZeroTapAlertViewController.xib"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/ar.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/cs.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/da.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/de.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/el.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/en-AU.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/en-GB.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/en.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/es-MX.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/es.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/fi.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/fr.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/he.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/hr.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/hu.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/id.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/it.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/ko.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/ms.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/nb.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/nl.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/pl.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/pt-PT.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/pt.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/ro.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/ru.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/sk.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/sv.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/th.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/tr.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/uk.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/vi.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/zh-Hans.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Accounts/l10n/zh-Hant.lproj"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_back_arrow_dark@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_back@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_back_center@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_back_cp@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_back_left@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_back_right@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_blue@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_blue_dark@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_cancel_center@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_cancel_left@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_cancel_right@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_gray@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_gray_arrow@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_primary_center@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_primary_left@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_primary_right@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_purple@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_purple_dark@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_purple_land@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_purple_land_dark@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_Q_gray@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_Q_purple@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_btn_secondary_center@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_bubble_top_center@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_bubble_top_left@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_bubble_top_right@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_bubble_under_center@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_bubble_under_left@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_bubble_under_right@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_field_text@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_field_text_error@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_field_text_selected@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_field_text_single@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_field_text_single_down@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_field_text_single_square@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_field_text_single_up@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_add_purple_dark@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_add_purple_light@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_add_yellow@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_back@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_facebook_square@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_facebook_wide@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_google_square@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_google_wide@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_info@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_remove_dark@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_remove_light@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_sso_avatar@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_text_clear@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_x@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_X_dark_theme@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_X_lt_theme@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_icn_yahoo_bang@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_logo_purple.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_logo_purple@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_logo_purple_small.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_logo_purple_small@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_logo_white.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_logo_white@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_logo_white_small.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_logo_white_small@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_overlay_light@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_profile_photo_unavailable@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/yaccounts_profile_user_unknown@2x.png"
install_resource "YAccountsSDK/FoundationSDK/SDKs/Accounts/ios/Framework/Assets/Settings.bundle"

rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ `xcrun --find actool` ] && [ `find . -name '*.xcassets' | wc -l` -ne 0 ]
then
  case "${TARGETED_DEVICE_FAMILY}" in 
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;  
  esac 
  find "${PWD}" -name "*.xcassets" -print0 | xargs -0 actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
