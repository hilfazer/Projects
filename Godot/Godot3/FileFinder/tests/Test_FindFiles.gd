extends "res://tests/GutTestBase.gd"

const FileFinderGd = preload("res://FileFinder.gd")

func test_findFilesInDirectory():

	var files = FileFinderGd.findFilesInDirectory("res://tests/files/test1")
	assert_eq(files.size(), 4)


var params1 = ParameterFactory.named_parameters(['ext', 'count'], \
	[[".txt", 3], [".ini", 1], ['.nnn', 0]] \
	)

func test_findFilesWithExtensionInDirectory(params=use_parameters(params1)):
	var files = FileFinderGd.findFilesInDirectory("res://tests/files/test1", params.ext)
	assert_eq(files.size(), params.count)

	var extensionMatches := 0
	for file in files:
		extensionMatches += int("." + file.get_extension() == params.ext)

	assert_eq(extensionMatches, params.count, "incorrect number of %s files" % params.ext)


func test_nonexistentDirectory():
	var files = FileFinderGd.findFilesInDirectory("res://doesnt_exist", ".txt")
	assert_eq(files.size(), 0)

	files = FileFinderGd.findFilesInDirectory("res://doesnt_exist", ".ini")
	assert_eq(files.size(), 0)
