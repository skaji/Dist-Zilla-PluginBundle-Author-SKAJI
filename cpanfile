requires "perl", '5.14.0';

requires "Dist::Zilla", "6.000";

requires "Archive::Tar::Wrapper";
requires "Pod::Markdown::Github";
requires "Devel::PPPort", "3.35";
requires "File::ShareDir::ProjectDistDir";

requires "Dist::Zilla::Plugin::CheckChangesHasContent";
requires "Dist::Zilla::Plugin::CopyFilesFromBuild";
requires "Dist::Zilla::Plugin::CopyFilesFromRelease";
requires "Dist::Zilla::Plugin::Git", "2.012";
requires "Dist::Zilla::Plugin::Git::Contributors", "0.009";
requires "Dist::Zilla::Plugin::GithubMeta";
requires "Dist::Zilla::Plugin::LicenseFromModule", "0.05";
requires "Dist::Zilla::Plugin::ModuleBuildTiny";
requires "Dist::Zilla::Plugin::Prereqs::FromCPANfile", "0.06";
requires "Dist::Zilla::Plugin::ReadmeAnyFromPod";
requires "Dist::Zilla::Plugin::ReversionOnRelease", "0.04";
requires "Dist::Zilla::Plugin::Test::Compile";
requires "Dist::Zilla::Plugin::VersionFromModule";
requires "Dist::Zilla::Role::PluginBundle::Config::Slicer";
requires "Dist::Zilla::Role::PluginBundle::PluginRemover";
