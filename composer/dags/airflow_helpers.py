from google.cloud import storage
from airflow.providers.google.cloud.hooks.dataflow import (_DataflowJobsController, DataflowJobStatus, DataflowJobType)
from airflow.providers.google.cloud.hooks.dataflow import (
    DEFAULT_DATAFLOW_LOCATION,
    DataflowHook,
    process_line_and_extract_dataflow_job_id_callback,
)


def check_files_in_bucket(bucket: str,
                          folder: str,
                          files_found_branch: str,
                          files_not_found_branch: str,
                          include_subfolders: bool = False,
                          *args,
                          **kwargs
                          ):

    # Check if files exists under processing folder and proceed accordingly

    storage_client = storage.Client()

    prefix = f"{folder}/"
    delimiter = None if include_subfolders else "/"

    blobs = storage_client.list_blobs(
        bucket,
        prefix=prefix,
        delimiter=delimiter,
        # We need to know if at least one object is there. .list_blobs return the folder root as well, so we use max=2
        max_results=2
    )
    counter = 0
    for blob in blobs:
        print(f"Listed object: {blob.name}")
        # in case the folder is empty, we will have the folder name listed
        if blob.name != prefix:
            counter += 1

    if counter > 0:
        return files_found_branch
    else:
        return files_not_found_branch


def check_dataflow_job_state(self, job) -> bool:
    """
    Helper method to check the state of one job in dataflow for this task
    if job failed raise exception
    :return: True if job is done.
    :rtype: bool
    :raise: Exception
    """
    print(self._wait_until_finished)
    print(job['currentState'])
    if self._wait_until_finished is None:
        wait_for_running = job.get('type') == DataflowJobType.JOB_TYPE_STREAMING
    else:
        wait_for_running = not self._wait_until_finished

    if job['currentState'] == DataflowJobStatus.JOB_STATE_DONE:
        return True
    elif job['currentState'] == DataflowJobStatus.JOB_STATE_FAILED:
        raise Exception(f"Google Cloud Dataflow job {job['name']} has failed.")
    elif job['currentState'] == DataflowJobStatus.JOB_STATE_CANCELLED:
        raise Exception(f"Google Cloud Dataflow job {job['name']} was cancelled.")
    elif job['currentState'] == DataflowJobStatus.JOB_STATE_DRAINED:
        raise Exception(f"Google Cloud Dataflow job {job['name']} was drained.")
    elif job['currentState'] == DataflowJobStatus.JOB_STATE_UPDATED:
        raise Exception(f"Google Cloud Dataflow job {job['name']} was updated.")
    elif job['currentState'] == DataflowJobStatus.JOB_STATE_RUNNING and wait_for_running:
        return True
    elif job['currentState'] in DataflowJobStatus.AWAITING_STATES:
        return self._wait_until_finished is False
    self.log.debug("Current job: %s", str(job))
    self.log.debug("Job Current state:  %s", str(job['currentState']))
    raise Exception(f"Google Cloud Dataflow job {job['name']} was unknown state: {job['currentState']}")


def check_dataflow_job_is_running(
        job_name: str,
        project_id: str,
        region: str,
        true_branch: str,
        false_branch: str,
        *args,
        **kwargs
) -> bool:

    hook = DataflowHook()

    is_running = hook.is_job_dataflow_running(
        name=job_name,
        project_id=project_id,
        location=region,
    )

    print(f"INFO: Job '{job_name}' in project {project_id} in region {region} is_running = '{is_running}' ")

    return true_branch if is_running else false_branch
