import sys


def set_mount_path(inputFolder, corralPrefix, tapisPrefix):
    inputDir = inputFolder.replace(tapisPrefix,'')
    mountPath = corralPrefix + inputDir             # /corral/projects/NHERI/shared/gedmonds/LAS/LAS_converted/"
    return mountPath


def main():
    folderToMount = sys.argv[1]

    prefixArr = [
        [
            "/corral/main/projects/NHERI/shared/", # "SHARED_PREFIX"
            "tapis://designsafe.storage.default/" #"SHARED_TAPISPREFIX"
        ],
        [
            "/corral/main/projects/NHERI/projects/", # "PROJECT_PREFIX"
            "tapis://project-" # "PROJECT_TAPISPREFIX"
        ],
        [
            "/corral/main/projects/NHERI/published/", # "PUBLISHED_PREFIX"
            "tapis://designsafe.storage.published" # "PUBLISHED_TAPISPREFIX" 
        ],
        [
            "/corral/main/projects/NHERI/community/", # "COMMUNITY_PREFIX"
            "tapis://designsafe.storage.community" # "COMMUNITY_TAPISPREFIX": 
        ]
    ]

    mountPath = None

    for prefixGroup in prefixArr:
        corralPrefix = prefixGroup[0]
        tapisPrefix = prefixGroup[1]
        if tapisPrefix in folderToMount:
                mountPath = set_mount_path(folderToMount, corralPrefix, tapisPrefix)
                break

    print(mountPath)

if __name__ == "__main__":
    main()
