const fs = require('fs');
const path = require('path');

const xcodeDir = path.join(process.cwd(), 'Gaurex.xcodeproj');
fs.mkdirSync(xcodeDir, { recursive: true });

function uuid(num) {
  return 'A' + String(num).padStart(23, '0');
}

let counter = 100;
function nextId() {
  return uuid(counter++);
}

const files = [
  'Gaurex/App/GaurexApp.swift',
  'Gaurex/App/AppLaunchExperienceView.swift',
  'Gaurex/DesignSystem/Theme/ThemeManager.swift',
  'Gaurex/DesignSystem/Theme/MotionTokens.swift',
  'Gaurex/DesignSystem/Theme/TypographyTokens.swift',
  'Gaurex/DesignSystem/Components/LiquidGlassTabBar.swift',
  'Gaurex/DesignSystem/Components/DesignComponents.swift',
  'Gaurex/Models/Package.swift',
  'Gaurex/Models/Client.swift',
  'Gaurex/Models/Invoice.swift',
  'Gaurex/Models/Payment.swift',
  'Gaurex/Models/Worker.swift',
  'Gaurex/Models/PayrollRecord.swift',
  'Gaurex/Models/BusinessSettings.swift',
  'Gaurex/Models/BusinessEntities.swift',
  'Gaurex/Models/Task.swift',
  'Gaurex/Models/SalesLead.swift',
  'Gaurex/Models/AttendanceAndLeave.swift',
  'Gaurex/Models/DocumentVaultItem.swift',
  'Gaurex/Models/BusinessGoal.swift',
  'Gaurex/Models/ExtendedBusinessModels.swift',
  'Gaurex/Services/FinancialCalculator.swift',
  'Gaurex/Services/PDFGeneratorService.swift',
  'Gaurex/Services/SecurityServices.swift',
  'Gaurex/Services/AuditAndBackupServices.swift',
  'Gaurex/Services/AIService.swift',
  'Gaurex/Services/FirestoreDataStore.swift',
  'Gaurex/Services/TaskPlannerService.swift',
  'Gaurex/Services/DocumentExtractionService.swift',
  'Gaurex/Services/VoiceAssistantService.swift',
  'Gaurex/Services/SmartReminderService.swift',
  'Gaurex/Views/MainTabView.swift',
  'Gaurex/Views/Dashboard/ChartsSectionView.swift',
  'Gaurex/Views/Dashboard/DashboardView.swift',
  'Gaurex/Views/Dashboard/FinanceProfitCenterView.swift',
  'Gaurex/Views/Dashboard/TodayTasksSectionView.swift',
  'Gaurex/Views/Dashboard/FounderCommandCenterView.swift',
  'Gaurex/Views/Clients/ClientsListView.swift',
  'Gaurex/Views/Clients/AddEditClientView.swift',
  'Gaurex/Views/Clients/ClientDetailView.swift',
  'Gaurex/Views/Clients/SalesPipelineView.swift',
  'Gaurex/Views/Invoices/InvoicesListView.swift',
  'Gaurex/Views/Invoices/CreateInvoiceView.swift',
  'Gaurex/Views/Invoices/PDFPreviewView.swift',
  'Gaurex/Views/Invoices/InvoiceDetailView.swift',
  'Gaurex/Views/Workers/WorkersListView.swift',
  'Gaurex/Views/Workers/AddEditWorkerView.swift',
  'Gaurex/Views/Workers/GenerateSalarySlipView.swift',
  'Gaurex/Views/Workers/WorkerDetailView.swift',
  'Gaurex/Views/Workers/AttendanceAndLeaveView.swift',
  'Gaurex/Views/AIModel/AIIntelligenceView.swift',
  'Gaurex/Views/AIModel/VoiceAssistantOverlay.swift',
  'Gaurex/Views/Settings/PackageManagementView.swift',
  'Gaurex/Views/Settings/BusinessSettingsAndAuditViews.swift',
  'Gaurex/Views/Settings/DocumentVaultView.swift',
  'Gaurex/Views/Settings/IntegrationsAndCurrencyViews.swift',
  'Gaurex/Views/Settings/SettingsView.swift'
];

const testFiles = [
  'GaurexTests/FinancialCalculationsTests.swift',
  'GaurexTests/PayrollAndPDFTests.swift',
  'GaurexTests/SecurityAndBackupTests.swift',
  'GaurexTests/ExtendedModulesTests.swift'
];

let buildFiles = [];
let fileRefs = [];
let mainGroupChildren = [];
let sourcesBuildPhase = [];
let testSourcesBuildPhase = [];
let testGroupChildren = [];

// App Files
for (const f of files) {
  const fId = nextId();
  const bId = nextId();
  const baseName = path.basename(f);
  fileRefs.push(`\t\t${fId} /* ${baseName} */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "${f}"; sourceTree = "<group>"; };`);
  buildFiles.push(`\t\t${bId} /* ${baseName} in Sources */ = {isa = PBXBuildFile; fileRef = ${fId} /* ${baseName} */; };`);
  mainGroupChildren.push(`\t\t\t\t${fId} /* ${baseName} */,`);
  sourcesBuildPhase.push(`\t\t\t\t${bId} /* ${baseName} in Sources */,`);
}

// Assets
const assetsFileId = nextId();
const assetsBuildId = nextId();
fileRefs.push(`\t\t${assetsFileId} /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = "Gaurex/Assets.xcassets"; sourceTree = "<group>"; };`);
buildFiles.push(`\t\t${assetsBuildId} /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = ${assetsFileId} /* Assets.xcassets */; };`);
mainGroupChildren.push(`\t\t\t\t${assetsFileId} /* Assets.xcassets */,`);

// Info.plist
const plistId = nextId();
fileRefs.push(`\t\t${plistId} /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = "Gaurex/Info.plist"; sourceTree = "<group>"; };`);
mainGroupChildren.push(`\t\t\t\t${plistId} /* Info.plist */,`);

// Entitlements
const entId = nextId();
fileRefs.push(`\t\t${entId} /* Gaurex.entitlements */ = {isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = "Gaurex/Gaurex.entitlements"; sourceTree = "<group>"; };`);
mainGroupChildren.push(`\t\t\t\t${entId} /* Gaurex.entitlements */,`);

// Test Files
for (const tf of testFiles) {
  const fId = nextId();
  const bId = nextId();
  const baseName = path.basename(tf);
  fileRefs.push(`\t\t${fId} /* ${baseName} */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "${tf}"; sourceTree = "<group>"; };`);
  buildFiles.push(`\t\t${bId} /* ${baseName} in Sources */ = {isa = PBXBuildFile; fileRef = ${fId} /* ${baseName} */; };`);
  testGroupChildren.push(`\t\t\t\t${fId} /* ${baseName} */,`);
  testSourcesBuildPhase.push(`\t\t\t\t${bId} /* ${baseName} in Sources */,`);
}

// Products
const appProductId = nextId();
fileRefs.push(`\t\t${appProductId} /* Gaurex.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Gaurex.app; sourceTree = BUILT_PRODUCTS_DIR; };`);

const testProductId = nextId();
fileRefs.push(`\t\t${testProductId} /* GaurexTests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = GaurexTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };`);

const appTargetId = nextId();
const testTargetId = nextId();
const pbxProjectId = nextId();
const mainGroupId = nextId();
const testGroupId = nextId();
const productsGroupId = nextId();
const rootGroupId = nextId();

const appSourcesPhaseId = nextId();
const appResourcesPhaseId = nextId();
const appFrameworksPhaseId = nextId();

const testSourcesPhaseId = nextId();
const testFrameworksPhaseId = nextId();
const testResourcesPhaseId = nextId();

const debugConfigAppId = nextId();
const releaseConfigAppId = nextId();
const debugConfigTestId = nextId();
const releaseConfigTestId = nextId();
const debugConfigProjId = nextId();
const releaseConfigProjId = nextId();

const projConfigListId = nextId();
const appConfigListId = nextId();
const testConfigListId = nextId();

const pbx = `// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
${buildFiles.join('\n')}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
${fileRefs.join('\n')}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		${appFrameworksPhaseId} /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		${testFrameworksPhaseId} /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		${rootGroupId} = {
			isa = PBXGroup;
			children = (
				${mainGroupId} /* Gaurex */,
				${testGroupId} /* GaurexTests */,
				${productsGroupId} /* Products */,
			);
			sourceTree = "<group>";
		};
		${mainGroupId} /* Gaurex */ = {
			isa = PBXGroup;
			children = (
${mainGroupChildren.join('\n')}
			);
			path = Gaurex;
			sourceTree = "<group>";
		};
		${testGroupId} /* GaurexTests */ = {
			isa = PBXGroup;
			children = (
${testGroupChildren.join('\n')}
			);
			path = GaurexTests;
			sourceTree = "<group>";
		};
		${productsGroupId} /* Products */ = {
			isa = PBXGroup;
			children = (
				${appProductId} /* Gaurex.app */,
				${testProductId} /* GaurexTests.xctest */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		${appTargetId} /* Gaurex */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = ${appConfigListId} /* Build configuration list for PBXNativeTarget "Gaurex" */;
			buildPhases = (
				${appSourcesPhaseId} /* Sources */,
				${appFrameworksPhaseId} /* Frameworks */,
				${appResourcesPhaseId} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = Gaurex;
			productName = Gaurex;
			productReference = ${appProductId} /* Gaurex.app */;
			productType = "com.apple.product-type.application";
		};
		${testTargetId} /* GaurexTests */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = ${testConfigListId} /* Build configuration list for PBXNativeTarget "GaurexTests" */;
			buildPhases = (
				${testSourcesPhaseId} /* Sources */,
				${testFrameworksPhaseId} /* Frameworks */,
				${testResourcesPhaseId} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = GaurexTests;
			productName = GaurexTests;
			productReference = ${testProductId} /* GaurexTests.xctest */;
			productType = "com.apple.product-type.bundle.unit-test";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		${pbxProjectId} /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastUpgradeCheck = 1540;
				TargetAttributes = {
					${appTargetId} = {
						CreatedOnToolsVersion = 15.4;
					};
					${testTargetId} = {
						CreatedOnToolsVersion = 15.4;
						TestTargetID = ${appTargetId};
					};
				};
			};
			buildConfigurationList = ${projConfigListId} /* Build configuration list for PBXProject "Gaurex" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = ${rootGroupId};
			productRefGroup = ${productsGroupId} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				${appTargetId} /* Gaurex */,
				${testTargetId} /* GaurexTests */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		${appResourcesPhaseId} /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				${assetsBuildId} /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		${testResourcesPhaseId} /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		${appSourcesPhaseId} /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
${sourcesBuildPhase.join('\n')}
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		${testSourcesPhaseId} /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
${testSourcesBuildPhase.join('\n')}
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		${debugConfigProjId} /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		${releaseConfigProjId} /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				SWIFT_VERSION = 5.0;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		${debugConfigAppId} /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = Gaurex/Gaurex.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Gaurex/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.gaurex.dashboard;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		${releaseConfigAppId} /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = Gaurex/Gaurex.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Gaurex/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.gaurex.dashboard;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
		${debugConfigTestId} /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.gaurex.dashboardTests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/Gaurex.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Gaurex";
			};
			name = Debug;
		};
		${releaseConfigTestId} /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.gaurex.dashboardTests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/Gaurex.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Gaurex";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		${projConfigListId} /* Build configuration list for PBXProject "Gaurex" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				${debugConfigProjId} /* Debug */,
				${releaseConfigProjId} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		${appConfigListId} /* Build configuration list for PBXNativeTarget "Gaurex" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				${debugConfigAppId} /* Debug */,
				${releaseConfigAppId} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		${testConfigListId} /* Build configuration list for PBXNativeTarget "GaurexTests" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				${debugConfigTestId} /* Debug */,
				${releaseConfigTestId} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */

	};
	rootObject = ${pbxProjectId} /* Project object */;
}
`;

fs.writeFileSync(path.join(xcodeDir, 'project.pbxproj'), pbx);
console.log('Gaurex.xcodeproj/project.pbxproj successfully regenerated with 57 files.');
