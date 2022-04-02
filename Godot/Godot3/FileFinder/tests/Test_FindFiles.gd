extends "res://tests/GutTestBase.gd"

const FileFinderGd = preload("res://FileFinder.gd")

func test_findFilesInDirectory():

	var files = FileFinderGd.findFilesInDirectory("res://tests/files/test1")
	assert_eq(files.size(), 4)


func test_findTxtFilesInDirectory():
	var files = FileFinderGd.findFilesInDirectory("res://tests/files/test1", ".txt")
	assert_eq(files.size(), 3)

	var extensionMatches := 0
	for file in files:
		extensionMatches += int("." + file.get_extension() == ".txt")

	assert_eq(extensionMatches, 3, "incorrect number of %s files" % ".txt")


func test_findIniFilesInDirectory():
	var files = FileFinderGd.findFilesInDirectory("res://tests/files/test1", ".ini")
	assert_eq(files.size(), 1)

	var extensionMatches := 0
	for file in files:
		extensionMatches += int("." + file.get_extension() == ".ini")

	assert_eq(extensionMatches, 1, "incorrect number of %s files" % ".ini")


func test_nonexistentDirectory():
	var files = FileFinderGd.findFilesInDirectory("res://doesnt_exist", ".txt")
	assert_eq(files.size(), 0)

	files = FileFinderGd.findFilesInDirectory("res://doesnt_exist", ".ini")
	assert_eq(files.size(), 0)
